import Darwin.Mach
import Foundation
import IOKit.ps

final class SystemResourceMonitor {
  private var previousCpuTicks: CpuTicks?

  func snapshot() -> SystemResourceSnapshot {
    let power = readPowerState()

    return SystemResourceSnapshot(
      cpuUsage: readCpuUsage(),
      batteryLevel: power.batteryLevel,
      isCharging: power.isCharging,
      isLowPowerModeEnabled: ProcessInfo.processInfo.isLowPowerModeEnabled,
      thermalState: ProcessInfo.processInfo.thermalState
    )
  }

  private func readCpuUsage() -> Double? {
    var info = host_cpu_load_info()
    var count = mach_msg_type_number_t(
      MemoryLayout<host_cpu_load_info_data_t>.stride / MemoryLayout<integer_t>.stride
    )

    let result = withUnsafeMutablePointer(to: &info) { pointer in
      pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { reboundPointer in
        host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, reboundPointer, &count)
      }
    }

    guard result == KERN_SUCCESS else { return nil }

    let current = CpuTicks(
      user: UInt64(info.cpu_ticks.0),
      system: UInt64(info.cpu_ticks.1),
      idle: UInt64(info.cpu_ticks.2),
      nice: UInt64(info.cpu_ticks.3)
    )

    defer {
      previousCpuTicks = current
    }

    guard let previousCpuTicks else { return nil }

    let user = current.user.saturatingSubtract(previousCpuTicks.user)
    let system = current.system.saturatingSubtract(previousCpuTicks.system)
    let idle = current.idle.saturatingSubtract(previousCpuTicks.idle)
    let nice = current.nice.saturatingSubtract(previousCpuTicks.nice)
    let total = user + system + idle + nice

    guard total > 0 else { return nil }
    return Double(total - idle) / Double(total)
  }

  private func readPowerState() -> (batteryLevel: Double?, isCharging: Bool?) {
    guard let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
          let sourceList = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [CFTypeRef] else {
      return (nil, nil)
    }

    for source in sourceList {
      guard let description = IOPSGetPowerSourceDescription(info, source)?
        .takeUnretainedValue() as? [String: Any] else {
        continue
      }

      let currentCapacity = numericValue(description[kIOPSCurrentCapacityKey as String])
      let maxCapacity = numericValue(description[kIOPSMaxCapacityKey as String])
      let state = description[kIOPSPowerSourceStateKey as String] as? String
      let isCharging = state == (kIOPSACPowerValue as String)

      if let currentCapacity, let maxCapacity, maxCapacity > 0 {
        return (currentCapacity / maxCapacity, isCharging)
      }
    }

    return (nil, nil)
  }

  private func numericValue(_ value: Any?) -> Double? {
    if let value = value as? Double {
      return value
    }

    if let value = value as? Int {
      return Double(value)
    }

    if let value = value as? NSNumber {
      return value.doubleValue
    }

    return nil
  }
}

private struct CpuTicks {
  let user: UInt64
  let system: UInt64
  let idle: UInt64
  let nice: UInt64
}

private extension UInt64 {
  func saturatingSubtract(_ other: UInt64) -> UInt64 {
    self >= other ? self - other : 0
  }
}

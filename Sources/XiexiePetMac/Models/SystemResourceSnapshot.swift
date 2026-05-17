import Foundation

struct SystemResourceSnapshot: Equatable {
  var cpuUsage: Double?
  var batteryLevel: Double?
  var isCharging: Bool?
  var isLowPowerModeEnabled: Bool
  var thermalState: ProcessInfo.ThermalState

  static let unknown = SystemResourceSnapshot(
    cpuUsage: nil,
    batteryLevel: nil,
    isCharging: nil,
    isLowPowerModeEnabled: ProcessInfo.processInfo.isLowPowerModeEnabled,
    thermalState: ProcessInfo.processInfo.thermalState
  )

  var isBatteryLow: Bool {
    guard let batteryLevel, isCharging != true else { return false }
    return batteryLevel <= 0.25
  }

  var isCpuBusy: Bool {
    guard let cpuUsage else { return false }
    return cpuUsage >= 0.65
  }

  var isThermallyConstrained: Bool {
    thermalState == .serious || thermalState == .critical
  }

  var shouldRest: Bool {
    isCpuBusy || isBatteryLow || isLowPowerModeEnabled || isThermallyConstrained
  }
}

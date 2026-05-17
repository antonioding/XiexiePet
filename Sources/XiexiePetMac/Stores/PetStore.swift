import Foundation
import SwiftUI

@MainActor
final class PetStore: ObservableObject {
  @Published var bubbles: [ThanksBubble] = []
  @Published var status = "它刚刚醒来，已经准备好感谢你了。"
  @Published var isHappy = false
  @Published var escapePhase: PetEscapePhase = .home
  @Published var isDragging = false
  @Published var isNapping = false
  @Published var edgeLean: Double = 0
  @Published var isNight = false
  @Published var systemResources = SystemResourceSnapshot.unknown
  @Published var companionMode: CompanionMode = .quiet

  var shouldRest: Bool {
    companionMode == .quiet || isNight || systemResources.shouldRest
  }

  private let thanks = [
    "谢谢",
    "谢谢你",
    "真的谢谢",
    "今天也谢谢你",
    "谢谢你在这里",
    "收到好意了，谢谢",
    "嘿嘿，谢谢",
    "你真好，谢谢"
  ]

  private let statuses = [
    "它在认真地把每一份好意都记下来。",
    "它刚刚又说了一次谢谢，很小声，但很真诚。",
    "它觉得今天因为你变亮了一点。",
    "它摇了摇尾巴，又补了一句谢谢。",
    "它把谢谢攒成一小堆，推到你面前。"
  ]

  private var thankTimer: Timer?
  private var statusTimer: Timer?
  private var resourceTimer: Timer?
  private var escapeTask: Task<Void, Never>?
  private var napTask: Task<Void, Never>?
  private let resourceMonitor = SystemResourceMonitor()
  private var lastPatDate = Date.distantPast
  private var patCount = 0
  private var statusIndex = 0

  func start() {
    guard thankTimer == nil else { return }

    isNight = Self.computeIsNight()
    refreshSystemResources()
    sayThanks("谢谢", extraHappy: true)
    scheduleThankTimer()
    scheduleStatusTimer()
    resourceTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
      Task { @MainActor in
        self?.refreshSystemResources()
      }
    }
    escapeTask = Task { [weak self] in
      await self?.runEscapeLoop()
    }
    napTask = Task { [weak self] in
      await self?.runNapLoop()
    }
  }

  func pat() {
    guard escapePhase == .home else { return }

    if isNapping {
      withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
        isNapping = false
      }
      sayThanks("醒啦，谢谢", extraHappy: true)
      return
    }

    registerPat()

    if patCount >= 4 {
      patCount = 0
      sayThanks("太多谢谢啦", extraHappy: true)
      return
    }

    sayThanks("谢谢你摸摸我", extraHappy: true)
    updateStatus()
  }

  func feedFood() {
    guard escapePhase == .home else { return }
    wakeIfNeeded()
    sayThanks("吃饱了，谢谢", extraHappy: true)
  }

  func feedWater() {
    guard escapePhase == .home else { return }
    wakeIfNeeded()
    sayThanks("咕嘟咕嘟，谢谢", extraHappy: true)
  }

  func feedMedicine() {
    guard escapePhase == .home else { return }
    wakeIfNeeded()
    bubbles = [ThanksBubble(message: "有点苦，但谢谢", x: 0.5, y: 0.24, drift: 0)]
  }

  func sleepNow() {
    guard escapePhase == .home, !isDragging else { return }
    bubbles = [ThanksBubble(message: "我睡啦，谢谢...", x: 0.5, y: 0.23, drift: 0)]

    withAnimation(.easeInOut(duration: 0.45)) {
      isNapping = true
    }
  }

  func wakeUp() {
    guard escapePhase == .home else { return }

    if isNapping {
      withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
        isNapping = false
      }
      sayThanks("醒啦，谢谢", extraHappy: true)
    } else {
      sayThanks("我醒着呢，谢谢", extraHappy: true)
    }
  }

  func setQuietCompanion() {
    companionMode = .quiet
    bubbles = [ThanksBubble(message: "安静陪你，谢谢", x: 0.5, y: 0.24, drift: 0)]
    rescheduleBehaviorTimers()
  }

  func setLivelyCompanion() {
    companionMode = .lively
    bubbles = [ThanksBubble(message: "我会活泼一点，谢谢", x: 0.5, y: 0.24, drift: 0)]
    rescheduleBehaviorTimers()
  }

  func beginDrag() {
    guard escapePhase == .home else { return }
    isDragging = true
    isNapping = false
    bubbles = [ThanksBubble(message: "哎呀，谢谢", x: 0.5, y: 0.24, drift: 0)]
  }

  func endDrag(edgeLean: Double) {
    isDragging = false
    withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
      self.edgeLean = edgeLean
    }
  }

  private func runEscapeLoop() async {
    while !Task.isCancelled {
      let range = shouldRest ? 180.0...420.0 : 70.0...150.0
      try? await Task.sleep(for: .seconds(Double.random(in: range)))
      await performRandomLittleHabit()
    }
  }

  private func runNapLoop() async {
    while !Task.isCancelled {
      isNight = Self.computeIsNight()
      refreshSystemResources()
      let range = shouldRest ? 90.0...210.0 : 70.0...150.0
      try? await Task.sleep(for: .seconds(Double.random(in: range)))
      await napBriefly()
    }
  }

  private func performRandomLittleHabit() async {
    guard escapePhase == .home, !isNapping, !isDragging else { return }
    guard companionMode == .lively else { return }
    guard !shouldRest || Int.random(in: 0...2) == 0 else { return }

    switch Int.random(in: 0...3) {
    case 0:
      await escapeAndReturn()
    case 1:
      await peek()
    case 2:
      await tailPeek()
    default:
      await peek()
    }
  }

  private func escapeAndReturn() async {
    bubbles = [ThanksBubble(message: "我溜一下", x: 0.5, y: 0.22, drift: 0)]

    withAnimation(.easeInOut(duration: 0.9)) {
      escapePhase = .leaving
    }

    try? await Task.sleep(for: .milliseconds(950))
    bubbles.removeAll()
    escapePhase = .hidden

    try? await Task.sleep(for: .seconds(Double.random(in: 1.4...2.6)))

    bubbles = [ThanksBubble(message: "我回来啦，谢谢", x: 0.5, y: 0.24, drift: 0)]

    withAnimation(.spring(response: 0.7, dampingFraction: 0.78)) {
      escapePhase = .returning
    }

    try? await Task.sleep(for: .milliseconds(720))

    withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
      escapePhase = .home
    }
  }

  private func peek() async {
    guard escapePhase == .home, !isNapping else { return }

    let fromLeft = Bool.random()
    bubbles = [ThanksBubble(message: "探头，谢谢", x: fromLeft ? 0.28 : 0.72, y: 0.24, drift: 0)]

    withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) {
      escapePhase = fromLeft ? .peekingLeft : .peekingRight
    }

    try? await Task.sleep(for: .milliseconds(1250))

    withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
      escapePhase = .home
    }
  }

  private func tailPeek() async {
    guard escapePhase == .home, !isNapping else { return }

    bubbles = [ThanksBubble(message: "尾巴也谢谢", x: 0.62, y: 0.26, drift: 0)]

    withAnimation(.easeInOut(duration: 0.55)) {
      escapePhase = .tailPeeking
    }

    try? await Task.sleep(for: .milliseconds(1100))

    withAnimation(.spring(response: 0.42, dampingFraction: 0.76)) {
      escapePhase = .home
    }
  }

  private func napBriefly() async {
    guard escapePhase == .home, !isDragging, !isNapping else { return }

    bubbles = [ThanksBubble(message: shouldRest ? "轻轻谢谢..." : "谢谢...", x: 0.5, y: 0.23, drift: 0)]

    withAnimation(.easeInOut(duration: 0.45)) {
      isNapping = true
    }

    try? await Task.sleep(for: .seconds(shouldRest ? 6.5 : 4.0))

    withAnimation(.easeInOut(duration: 0.25)) {
      isNapping = false
    }
  }

  private func sayThanks(_ message: String? = nil, extraHappy: Bool = false) {
    guard escapePhase == .home, !isNapping, !isDragging else { return }
    guard companionMode == .lively || message != nil else { return }
    guard !shouldRest || message != nil || Int.random(in: 0...1) == 0 else { return }

    let bubble = ThanksBubble(
      message: message ?? randomThanks(),
      x: Double.random(in: 0.30...0.70),
      y: Double.random(in: 0.20...0.32),
      drift: Double.random(in: -62...62)
    )

    bubbles = [bubble]

    if extraHappy {
      isHappy = false
      isHappy = true
      Task { @MainActor in
        try? await Task.sleep(for: .milliseconds(560))
        isHappy = false
      }
    }

    Task { @MainActor in
      try? await Task.sleep(for: .milliseconds(2400))
      bubbles.removeAll { $0.id == bubble.id }
    }
  }

  private func updateStatus() {
    status = statuses[statusIndex % statuses.count]
    statusIndex += 1
  }

  private func randomThanks() -> String {
    if systemResources.isCpuBusy, Int.random(in: 0...3) == 0 {
      return "电脑忙，我轻轻谢谢"
    }

    if systemResources.isBatteryLow, Int.random(in: 0...3) == 0 {
      return "省点电，谢谢"
    }

    if shouldRest, Int.random(in: 0...4) == 0 {
      return "轻轻谢谢"
    }

    if isNight, Int.random(in: 0...4) == 0 {
      return "晚安，谢谢"
    }

    return thanks.randomElement() ?? "谢谢"
  }

  private func registerPat() {
    let now = Date()
    if now.timeIntervalSince(lastPatDate) < 1.8 {
      patCount += 1
    } else {
      patCount = 1
    }
    lastPatDate = now
  }

  private func wakeIfNeeded() {
    if isNapping {
      withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
        isNapping = false
      }
    }
  }

  private static func computeIsNight() -> Bool {
    let hour = Calendar.current.component(.hour, from: Date())
    return hour >= 22 || hour < 7
  }

  private func refreshSystemResources() {
    isNight = Self.computeIsNight()
    systemResources = resourceMonitor.snapshot()
    rescheduleBehaviorTimers()
  }

  private func scheduleThankTimer() {
    thankTimer?.invalidate()
    let interval = shouldRest ? Double.random(in: 75...140) : Double.random(in: 28...55)
    thankTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
      Task { @MainActor in
        self?.sayThanks()
      }
    }
  }

  private func scheduleStatusTimer() {
    statusTimer?.invalidate()
    let interval = shouldRest ? Double.random(in: 180...300) : Double.random(in: 90...150)
    statusTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
      Task { @MainActor in
        self?.updateStatus()
      }
    }
  }

  private func rescheduleBehaviorTimers() {
    scheduleThankTimer()
    scheduleStatusTimer()
  }
}

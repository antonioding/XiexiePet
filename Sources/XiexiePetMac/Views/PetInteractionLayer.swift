import AppKit
import SwiftUI

struct PetInteractionLayer: NSViewRepresentable {
  let onClick: () -> Void
  let onClose: () -> Void
  let onFeedFood: () -> Void
  let onFeedWater: () -> Void
  let onFeedMedicine: () -> Void
  let onWake: () -> Void
  let onSleep: () -> Void
  let onQuietCompanion: () -> Void
  let onLivelyCompanion: () -> Void
  let onDragStart: () -> Void
  let onDragEnd: (Double) -> Void

  func makeCoordinator() -> Coordinator {
    Coordinator(
      onClick: onClick,
      onClose: onClose,
      onFeedFood: onFeedFood,
      onFeedWater: onFeedWater,
      onFeedMedicine: onFeedMedicine,
      onWake: onWake,
      onSleep: onSleep,
      onQuietCompanion: onQuietCompanion,
      onLivelyCompanion: onLivelyCompanion,
      onDragStart: onDragStart,
      onDragEnd: onDragEnd
    )
  }

  func makeNSView(context: Context) -> NSView {
    let view = InteractionView()
    view.coordinator = context.coordinator
    return view
  }

  func updateNSView(_ nsView: NSView, context: Context) {
    context.coordinator.onClick = onClick
    context.coordinator.onClose = onClose
    context.coordinator.onFeedFood = onFeedFood
    context.coordinator.onFeedWater = onFeedWater
    context.coordinator.onFeedMedicine = onFeedMedicine
    context.coordinator.onWake = onWake
    context.coordinator.onSleep = onSleep
    context.coordinator.onQuietCompanion = onQuietCompanion
    context.coordinator.onLivelyCompanion = onLivelyCompanion
    context.coordinator.onDragStart = onDragStart
    context.coordinator.onDragEnd = onDragEnd

    if let view = nsView as? InteractionView {
      view.coordinator = context.coordinator
    }
  }

  final class Coordinator: NSObject {
    var onClick: () -> Void
    var onClose: () -> Void
    var onFeedFood: () -> Void
    var onFeedWater: () -> Void
    var onFeedMedicine: () -> Void
    var onWake: () -> Void
    var onSleep: () -> Void
    var onQuietCompanion: () -> Void
    var onLivelyCompanion: () -> Void
    var onDragStart: () -> Void
    var onDragEnd: (Double) -> Void

    init(
      onClick: @escaping () -> Void,
      onClose: @escaping () -> Void,
      onFeedFood: @escaping () -> Void,
      onFeedWater: @escaping () -> Void,
      onFeedMedicine: @escaping () -> Void,
      onWake: @escaping () -> Void,
      onSleep: @escaping () -> Void,
      onQuietCompanion: @escaping () -> Void,
      onLivelyCompanion: @escaping () -> Void,
      onDragStart: @escaping () -> Void,
      onDragEnd: @escaping (Double) -> Void
    ) {
      self.onClick = onClick
      self.onClose = onClose
      self.onFeedFood = onFeedFood
      self.onFeedWater = onFeedWater
      self.onFeedMedicine = onFeedMedicine
      self.onWake = onWake
      self.onSleep = onSleep
      self.onQuietCompanion = onQuietCompanion
      self.onLivelyCompanion = onLivelyCompanion
      self.onDragStart = onDragStart
      self.onDragEnd = onDragEnd
    }

    @objc func feedFood() {
      onFeedFood()
    }

    @objc func feedWater() {
      onFeedWater()
    }

    @objc func feedMedicine() {
      onFeedMedicine()
    }

    @objc func wakePet() {
      onWake()
    }

    @objc func sleepPet() {
      onSleep()
    }

    @objc func quietCompanion() {
      onQuietCompanion()
    }

    @objc func livelyCompanion() {
      onLivelyCompanion()
    }

    @objc func closePet() {
      onClose()
    }
  }
}

private final class InteractionView: NSView {
  weak var coordinator: PetInteractionLayer.Coordinator?
  private var trackingArea: NSTrackingArea?

  override var acceptsFirstResponder: Bool {
    true
  }

  override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
    true
  }

  override func updateTrackingAreas() {
    super.updateTrackingAreas()

    if let trackingArea {
      removeTrackingArea(trackingArea)
    }

    let options: NSTrackingArea.Options = [
      .activeAlways,
      .cursorUpdate,
      .inVisibleRect,
      .mouseEnteredAndExited
    ]
    let area = NSTrackingArea(rect: .zero, options: options, owner: self)
    trackingArea = area
    addTrackingArea(area)
  }

  override func resetCursorRects() {
    super.resetCursorRects()
    addCursorRect(bounds, cursor: .openHand)
  }

  override func cursorUpdate(with event: NSEvent) {
    NSCursor.openHand.set()
  }

  override func mouseEntered(with event: NSEvent) {
    NSCursor.openHand.set()
  }

  override func mouseExited(with event: NSEvent) {
    NSCursor.arrow.set()
  }

  override func mouseDown(with event: NSEvent) {
    guard let window else { return }

    var didDrag = false
    let clickLocation = event.locationInWindow
    NSCursor.closedHand.set()

    while true {
      guard let nextEvent = window.nextEvent(
        matching: [.leftMouseDragged, .leftMouseUp],
        until: .distantFuture,
        inMode: .eventTracking,
        dequeue: true
      ) else {
        break
      }

      switch nextEvent.type {
      case .leftMouseDragged:
        didDrag = true
        coordinator?.onDragStart()
        window.performDrag(with: event)
        coordinator?.onDragEnd(edgeLean(for: window))
        NSCursor.openHand.set()
        return
      case .leftMouseUp:
        let releaseLocation = nextEvent.locationInWindow
        let distance = hypot(
          releaseLocation.x - clickLocation.x,
          releaseLocation.y - clickLocation.y
        )
        if !didDrag && distance < 4 {
          coordinator?.onClick()
        }
        NSCursor.openHand.set()
        return
      default:
        break
      }
    }

    NSCursor.openHand.set()
  }

  override func rightMouseDown(with event: NSEvent) {
    guard let menu = menu(for: event) else { return }
    NSMenu.popUpContextMenu(menu, with: event, for: self)
  }

  override func menu(for event: NSEvent) -> NSMenu? {
    let menu = NSMenu()
    menu.addItem(menuItem("喂饭", #selector(PetInteractionLayer.Coordinator.feedFood)))
    menu.addItem(menuItem("喂水", #selector(PetInteractionLayer.Coordinator.feedWater)))
    menu.addItem(menuItem("喂药", #selector(PetInteractionLayer.Coordinator.feedMedicine)))
    menu.addItem(.separator())
    menu.addItem(menuItem("拍醒", #selector(PetInteractionLayer.Coordinator.wakePet)))
    menu.addItem(menuItem("睡觉", #selector(PetInteractionLayer.Coordinator.sleepPet)))
    menu.addItem(.separator())
    menu.addItem(menuItem("安静陪伴", #selector(PetInteractionLayer.Coordinator.quietCompanion)))
    menu.addItem(menuItem("活泼一点", #selector(PetInteractionLayer.Coordinator.livelyCompanion)))
    menu.addItem(.separator())
    menu.addItem(menuItem("关闭宠物", #selector(PetInteractionLayer.Coordinator.closePet)))
    return menu
  }

  private func menuItem(_ title: String, _ action: Selector) -> NSMenuItem {
    let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
    item.target = coordinator
    return item
  }

  private func edgeLean(for window: NSWindow) -> Double {
    guard let visibleFrame = window.screen?.visibleFrame else { return 0 }

    if window.frame.minX <= visibleFrame.minX + 18 {
      return -1
    }

    if window.frame.maxX >= visibleFrame.maxX - 18 {
      return 1
    }

    return 0
  }
}

import AppKit
import SwiftUI

final class PetWindowController: ObservableObject {
  weak var window: NSWindow?
  private var didSetInitialSize = false

  func attach(_ window: NSWindow) {
    self.window = window
    window.styleMask = [.borderless, .resizable]
    window.minSize = NSSize(width: 120, height: 150)
    window.isOpaque = false
    window.backgroundColor = .clear
    window.hasShadow = true
    window.level = .floating
    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    window.titleVisibility = .hidden
    window.titlebarAppearsTransparent = true
    window.isMovableByWindowBackground = true

    window.standardWindowButton(.closeButton)?.isHidden = true
    window.standardWindowButton(.miniaturizeButton)?.isHidden = true
    window.standardWindowButton(.zoomButton)?.isHidden = true

    if !didSetInitialSize {
      window.setContentSize(NSSize(width: 190, height: 230))
      window.center()
      didSetInitialSize = true
    }
  }

  func showPet() {
    guard let window else { return }
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  func hidePet() {
    window?.orderOut(nil)
  }
}

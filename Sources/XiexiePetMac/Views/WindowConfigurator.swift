import AppKit
import SwiftUI

struct WindowConfigurator: NSViewRepresentable {
  let controller: PetWindowController

  func makeNSView(context: Context) -> NSView {
    let view = NSView()
    DispatchQueue.main.async {
      if let window = view.window {
        controller.attach(window)
      }
    }
    return view
  }

  func updateNSView(_ nsView: NSView, context: Context) {
    DispatchQueue.main.async {
      if let window = nsView.window {
        controller.attach(window)
      }
    }
  }
}

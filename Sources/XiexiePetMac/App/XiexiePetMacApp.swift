import SwiftUI

@main
struct XiexiePetMacApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
  @StateObject private var petStore = PetStore()
  @StateObject private var windowController = PetWindowController()

  var body: some Scene {
    WindowGroup("谢谢小宠物") {
      ContentView()
        .environmentObject(petStore)
        .environmentObject(windowController)
        .frame(width: 190, height: 230)
        .background(WindowConfigurator(controller: windowController))
        .onAppear {
          petStore.start()
        }
    }
    .windowStyle(.hiddenTitleBar)
    .windowResizability(.automatic)

    MenuBarExtra("谢谢宠物", systemImage: "pawprint.fill") {
      PetMenuCommandsView(
        petStore: petStore,
        windowController: windowController
      )
    }

    Settings {
      SettingsView()
    }
  }
}

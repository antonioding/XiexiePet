import SwiftUI

struct PetMenuCommandsView: View {
  @ObservedObject var petStore: PetStore
  @ObservedObject var windowController: PetWindowController

  var body: some View {
    Button("显示宠物") {
      windowController.showPet()
    }

    Button("隐藏宠物") {
      windowController.hidePet()
    }

    Divider()

    Button("喂饭") {
      petStore.feedFood()
    }

    Button("喂水") {
      petStore.feedWater()
    }

    Button("喂药") {
      petStore.feedMedicine()
    }

    Divider()

    Button("拍醒") {
      petStore.wakeUp()
    }

    Button("睡觉") {
      petStore.sleepNow()
    }

    Divider()

    Button("安静陪伴") {
      petStore.setQuietCompanion()
    }

    Button("活泼一点") {
      petStore.setLivelyCompanion()
    }

    Divider()

    Button("关闭宠物") {
      NSApp.terminate(nil)
    }
  }
}

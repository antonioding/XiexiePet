import SwiftUI

struct SettingsView: View {
  var body: some View {
    Form {
      Text("谢谢小宠物会一直陪你说谢谢。")
        .foregroundStyle(.secondary)
    }
    .padding(24)
    .frame(width: 320)
  }
}

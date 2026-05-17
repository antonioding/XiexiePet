import SwiftUI

struct ContentView: View {
  @EnvironmentObject private var petStore: PetStore

  var body: some View {
    GeometryReader { proxy in
      let width = proxy.size.width
      let height = proxy.size.height
      let petSize = min(width * 0.78, height * 0.66)
      let petEscapeOffset = escapeOffset(width: width, height: height)
      let shadowOpacity = petStore.escapePhase == .hidden || petStore.escapePhase == .tailPeeking ? 0.0 : 0.14

      ZStack {
        BubbleLayerView(bubbles: petStore.bubbles)
          .frame(width: width, height: height)

        Ellipse()
          .fill(Color(red: 0.24, green: 0.18, blue: 0.12).opacity(shadowOpacity))
          .frame(width: petSize * 0.78, height: max(16, petSize * 0.11))
          .blur(radius: 1.4)
          .offset(y: height * 0.38)
          .opacity(petStore.escapePhase.isGone ? 0 : 1)
          .animation(.easeInOut(duration: 0.35), value: petStore.escapePhase)

        PetView(
          isHappy: petStore.isHappy,
          isDragging: petStore.isDragging,
          isNapping: petStore.isNapping,
          edgeLean: petStore.edgeLean,
          isRestingMode: petStore.shouldRest
        )
          .frame(width: petSize, height: petSize)
          .accessibilityLabel("摸摸谢谢小宠物")
          .offset(
            x: petEscapeOffset.width,
            y: height * 0.17 + petEscapeOffset.height
          )
          .opacity(petStore.escapePhase == .hidden ? 0 : 1)
          .animation(.spring(response: 0.72, dampingFraction: 0.82), value: petStore.escapePhase)

        PetInteractionLayer(
          onClick: {
            petStore.pat()
          },
          onClose: {
            NSApp.terminate(nil)
          },
          onFeedFood: {
            petStore.feedFood()
          },
          onFeedWater: {
            petStore.feedWater()
          },
          onFeedMedicine: {
            petStore.feedMedicine()
          },
          onWake: {
            petStore.wakeUp()
          },
          onSleep: {
            petStore.sleepNow()
          },
          onQuietCompanion: {
            petStore.setQuietCompanion()
          },
          onLivelyCompanion: {
            petStore.setLivelyCompanion()
          },
          onDragStart: {
            petStore.beginDrag()
          },
          onDragEnd: { edgeLean in
            petStore.endDrag(edgeLean: edgeLean)
          }
        )
        .frame(width: max(0, width - 16), height: max(0, height - 16))
      }
    }
  }

  private func escapeOffset(width: CGFloat, height: CGFloat) -> CGSize {
    switch petStore.escapePhase {
    case .home:
      return .zero
    case .leaving, .hidden:
      return CGSize(width: width * 0.95, height: -height * 0.10)
    case .returning:
      return CGSize(width: -width * 0.92, height: height * 0.06)
    case .peekingLeft:
      return CGSize(width: -width * 0.46, height: height * 0.05)
    case .peekingRight:
      return CGSize(width: width * 0.46, height: height * 0.05)
    case .tailPeeking:
      return CGSize(width: -width * 0.68, height: height * 0.14)
    }
  }
}

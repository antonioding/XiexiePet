import SwiftUI

struct BubbleLayerView: View {
  let bubbles: [ThanksBubble]

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        ForEach(bubbles) { bubble in
          ThanksBubbleView(bubble: bubble)
            .position(
              x: proxy.size.width * bubble.x,
              y: proxy.size.height * bubble.y
            )
        }
      }
    }
    .allowsHitTesting(false)
  }
}

private struct ThanksBubbleView: View {
  let bubble: ThanksBubble
  @State private var isVisible = false

  var body: some View {
    Text(bubble.message)
      .font(.system(size: 15, weight: .semibold, design: .rounded))
      .foregroundStyle(Color(red: 0.15, green: 0.21, blue: 0.19))
      .padding(.horizontal, 14)
      .padding(.vertical, 10)
      .background(.white.opacity(0.86), in: Capsule())
      .overlay {
        Capsule()
          .stroke(.white.opacity(0.68), lineWidth: 1)
      }
      .shadow(color: Color(red: 0.30, green: 0.21, blue: 0.16).opacity(0.16), radius: 18, y: 10)
      .opacity(isVisible ? 0 : 1)
      .scaleEffect(isVisible ? 1.08 : 0.82)
      .offset(x: isVisible ? bubble.drift : 0, y: isVisible ? -36 : 0)
      .onAppear {
        withAnimation(.easeOut(duration: 3.2)) {
          isVisible = true
        }
      }
  }
}

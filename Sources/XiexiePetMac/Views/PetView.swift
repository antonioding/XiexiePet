import SwiftUI

struct PetView: View {
  let isHappy: Bool
  let isDragging: Bool
  let isNapping: Bool
  let edgeLean: Double
  let isRestingMode: Bool
  @State private var isBlinking = false
  @State private var isBreathing = false

  var body: some View {
    GeometryReader { proxy in
      let scale = min(proxy.size.width, proxy.size.height) / 310

      ZStack {
        TailShape()
          .stroke(Color(red: 0.94, green: 0.70, blue: 0.42), style: StrokeStyle(lineWidth: 24, lineCap: .round))
          .frame(width: 92, height: 92)
          .rotationEffect(.degrees(isHappy ? 42 : 28))
          .offset(x: 130, y: 58)
          .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isHappy)

        EarView()
          .rotationEffect(.degrees(-28))
          .offset(x: -82, y: -112)

        EarView()
          .rotationEffect(.degrees(28))
          .offset(x: 82, y: -112)

        BodyShape()
          .fill(
            RadialGradient(
              colors: [
                Color(red: 0.96, green: 0.76, blue: 0.48).opacity(0.46),
                Color(red: 1.0, green: 0.97, blue: 0.89),
                Color(red: 1.0, green: 0.99, blue: 0.94)
              ],
              center: UnitPoint(x: 0.5, y: 0.78),
              startRadius: 18,
              endRadius: 170
            )
          )
          .frame(width: 310, height: 310)
          .shadow(color: Color(red: 0.33, green: 0.22, blue: 0.15).opacity(0.24), radius: 34, y: 18)
          .overlay {
            BodyShape()
              .stroke(.white.opacity(0.42), lineWidth: 4)
          }
          .overlay(alignment: .topLeading) {
            Ellipse()
              .fill(.white.opacity(0.28))
              .frame(width: 118, height: 76)
              .blur(radius: 10)
              .offset(x: 46, y: 38)
          }
          .overlay(alignment: .bottom) {
            Ellipse()
              .fill(Color(red: 0.96, green: 0.74, blue: 0.44).opacity(0.20))
              .frame(width: 210, height: 38)
              .padding(.bottom, 5)
          }

        FaceView(isBlinking: isBlinking || isNapping, isDragging: isDragging)

        PawView()
          .rotationEffect(.degrees(10))
          .offset(x: -56, y: 104)

        PawView()
          .rotationEffect(.degrees(-10))
          .offset(x: 56, y: 104)
      }
      .frame(width: 310, height: 310)
      .scaleEffect(scale * (isHappy ? 1.04 : 1) * (isDragging ? 0.97 : 1) * (isBreathing ? 1.018 : 1))
      .frame(width: proxy.size.width, height: proxy.size.height)
      .offset(y: (isHappy ? -16 * scale : 0) + (isBreathing ? -2 * scale : 0))
      .rotationEffect(.degrees(edgeLean * 8 + (isDragging ? -3 : 0)))
      .animation(.spring(response: 0.36, dampingFraction: 0.58), value: isHappy)
      .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isDragging)
      .animation(.spring(response: 0.45, dampingFraction: 0.7), value: edgeLean)
    }
    .task {
      await blinkLoop()
    }
    .onAppear {
      withAnimation(.easeInOut(duration: isRestingMode ? 2.8 : 2.1).repeatForever(autoreverses: true)) {
        isBreathing = true
      }
    }
  }

  private func blinkLoop() async {
    while !Task.isCancelled {
      let pause: UInt64 = isRestingMode
        ? UInt64.random(in: 3_800_000_000...7_400_000_000)
        : UInt64.random(in: 2_400_000_000...5_800_000_000)
      try? await Task.sleep(nanoseconds: pause)

      await MainActor.run {
        withAnimation(.easeInOut(duration: 0.08)) {
          isBlinking = true
        }
      }

      try? await Task.sleep(nanoseconds: 120_000_000)

      await MainActor.run {
        withAnimation(.easeInOut(duration: 0.09)) {
          isBlinking = false
        }
      }
    }
  }
}

private struct EarView: View {
  var body: some View {
    OvalEarShape()
      .fill(Color(red: 0.94, green: 0.70, blue: 0.42))
      .frame(width: 80, height: 98)
      .overlay {
        OvalEarShape()
          .fill(Color(red: 1.0, green: 0.88, blue: 0.72))
          .padding(.horizontal, 18)
          .padding(.vertical, 18)
      }
      .overlay {
        OvalEarShape()
          .stroke(.white.opacity(0.36), lineWidth: 3)
      }
  }
}

private struct FaceView: View {
  let isBlinking: Bool
  let isDragging: Bool

  var body: some View {
    ZStack {
      EyeView(isBlinking: isBlinking, isDragging: isDragging)
        .offset(x: -54, y: -18)

      EyeView(isBlinking: isBlinking, isDragging: isDragging)
        .offset(x: 54, y: -18)

      Capsule()
        .fill(Color(red: 0.92, green: 0.44, blue: 0.29).opacity(isDragging ? 0.34 : 0.22))
        .frame(width: 46, height: 24)
        .offset(x: -78, y: 34)

      Capsule()
        .fill(Color(red: 0.92, green: 0.44, blue: 0.29).opacity(isDragging ? 0.34 : 0.22))
        .frame(width: 46, height: 24)
        .offset(x: 78, y: 34)

      MouthShape()
        .stroke(Color(red: 0.14, green: 0.19, blue: 0.18), style: StrokeStyle(lineWidth: 4.5, lineCap: .round))
        .frame(width: 54, height: 22)
        .offset(y: 28)
    }
  }
}

private struct EyeView: View {
  let isBlinking: Bool
  let isDragging: Bool

  var body: some View {
    Circle()
      .fill(Color(red: 0.14, green: 0.19, blue: 0.18))
      .frame(width: isDragging ? 26 : 34, height: isDragging ? 26 : 34)
      .scaleEffect(x: 1, y: isBlinking ? 0.12 : 1)
      .overlay(alignment: .topLeading) {
        Circle()
          .fill(.white)
          .frame(width: 10, height: 10)
          .offset(x: 8, y: 7)
          .opacity(isBlinking ? 0 : 1)
      }
      .overlay(alignment: .bottomTrailing) {
        Circle()
          .fill(.white.opacity(0.45))
          .frame(width: 5, height: 5)
          .offset(x: -7, y: -6)
          .opacity(isBlinking ? 0 : 1)
      }
  }
}

private struct PawView: View {
  var body: some View {
    Capsule()
      .fill(Color(red: 1.0, green: 0.89, blue: 0.70).opacity(0.72))
      .frame(width: 58, height: 42)
      .shadow(color: Color(red: 0.95, green: 0.75, blue: 0.49).opacity(0.18), radius: 0, y: 5)
  }
}

private struct BodyShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.05))
    path.addCurve(
      to: CGPoint(x: rect.maxX - rect.width * 0.05, y: rect.midY + rect.height * 0.04),
      control1: CGPoint(x: rect.maxX - rect.width * 0.20, y: rect.minY),
      control2: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.21)
    )
    path.addCurve(
      to: CGPoint(x: rect.midX, y: rect.maxY - rect.height * 0.03),
      control1: CGPoint(x: rect.maxX, y: rect.maxY - rect.height * 0.16),
      control2: CGPoint(x: rect.maxX - rect.width * 0.21, y: rect.maxY)
    )
    path.addCurve(
      to: CGPoint(x: rect.minX + rect.width * 0.05, y: rect.midY + rect.height * 0.04),
      control1: CGPoint(x: rect.minX + rect.width * 0.21, y: rect.maxY),
      control2: CGPoint(x: rect.minX, y: rect.maxY - rect.height * 0.16)
    )
    path.addCurve(
      to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.05),
      control1: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.21),
      control2: CGPoint(x: rect.minX + rect.width * 0.20, y: rect.minY)
    )
    path.closeSubpath()
    return path
  }
}

private struct OvalEarShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.addEllipse(in: rect)
    return path
  }
}

private struct MouthShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.midY))
    path.addQuadCurve(
      to: CGPoint(x: rect.maxX, y: rect.midY),
      control: CGPoint(x: rect.midX, y: rect.maxY)
    )
    return path
  }
}

private struct TailShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.addArc(
      center: CGPoint(x: rect.midX, y: rect.midY),
      radius: min(rect.width, rect.height) * 0.42,
      startAngle: .degrees(-42),
      endAngle: .degrees(212),
      clockwise: false
    )
    return path
  }
}

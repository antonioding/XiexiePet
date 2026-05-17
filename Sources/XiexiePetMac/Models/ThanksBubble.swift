import Foundation

struct ThanksBubble: Identifiable, Equatable {
  let id = UUID()
  let message: String
  let x: Double
  let y: Double
  let drift: Double
}

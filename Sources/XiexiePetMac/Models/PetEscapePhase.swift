import Foundation

enum PetEscapePhase: Equatable {
  case home
  case leaving
  case hidden
  case returning
  case peekingLeft
  case peekingRight
  case tailPeeking

  var isGone: Bool {
    self == .leaving || self == .hidden
  }

  var isBusy: Bool {
    self != .home
  }
}

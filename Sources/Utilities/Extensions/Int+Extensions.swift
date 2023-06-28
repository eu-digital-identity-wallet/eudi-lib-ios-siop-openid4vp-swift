import Foundation

extension Int {
  func isWithinRange(_ range: ClosedRange<Int>) -> Bool {
    return range.contains(self)
  }
}

import Foundation

public extension Int {
  public func isWithinRange(_ range: ClosedRange<Int>) -> Bool {
    return range.contains(self)
  }
}

import Foundation

public enum DecentralizedIdentifier: Equatable {
  case did(String)

  /// Returns the string representation of the Decentralized Identifier.
  var stringValue: String {
    switch self {
    case .did(let value):
      return value
    }
  }

  /// Validates the format of the Decentralized Identifier.
  ///
  /// - Returns: A Boolean value indicating whether the DID is valid.
  func isValid() -> Bool {
    switch self {
    case .did(let value):
      let regexPattern = "^did:[a-z0-9]+:[a-zA-Z0-9_.-]+$"
      guard let regex = try? NSRegularExpression(pattern: regexPattern, options: []) else {
        return false
      }
      let range = NSRange(location: 0, length: value.utf16.count)
      let matches = regex.matches(in: value, options: [], range: range)
      return !matches.isEmpty
    }
  }
}

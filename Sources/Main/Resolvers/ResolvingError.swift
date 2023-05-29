import Foundation

/// An enumeration representing errors that can occur during the resolution of presentation definitions.
public enum ResolvingError: LocalizedError {
  /// The source for resolving presentation definitions is invalid.
  case invalidSource

  /// The specified scopes for resolving presentation definitions are invalid.
  case invalidScopes

  /// A localized description of the error.
  public var errorDescription: String? {
    switch self {
    case .invalidSource:
      return ".invalidSource"
    case .invalidScopes:
      return ".invalidScopes"
    }
  }
}

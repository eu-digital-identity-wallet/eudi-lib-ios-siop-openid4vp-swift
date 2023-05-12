import Foundation

public enum ResolvingError: LocalizedError {
  case invalidSource
  case invalidScopes

  public var errorDescription: String? {
    switch self {
    case .invalidSource:
      return ".invalidSource"
    case .invalidScopes:
      return ".invalidScopes"
    }
  }
}

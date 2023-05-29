import Foundation

/// An enumeration representing the possible errors encountered during authorization resolution.
public enum ResolvedAuthorisationError: LocalizedError {
  case invalidClientData
  case invalidPresentationDefinitionData
  case unsupportedResponseType(String)

  /// A computed property that returns a localized description of the error.
  public var errorDescription: String? {
    switch self {
    case .invalidClientData:
      return ".invalidClientData"
    case .invalidPresentationDefinitionData:
      return ".invalidPresentationDefinitionData"
    case .unsupportedResponseType(let type):
      return ".unsupportedResponseType \(type)"
    }
  }
}

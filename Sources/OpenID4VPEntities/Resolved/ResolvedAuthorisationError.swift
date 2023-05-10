import Foundation

public enum ResolvedAuthorisationError: LocalizedError {
  case invalidClientData
  case invalidPresentationDefinitionData
  case unsupportedResponseType(String)

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

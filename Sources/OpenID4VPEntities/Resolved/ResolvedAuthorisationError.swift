import Foundation

public enum ResolvedAuthorisationError: LocalizedError {
  case invalidClientData
  case invalidPresentationDefinitionData

  public var errorDescription: String? {
    switch self {
    case .invalidClientData:
      return ".invalidClientData"
    case .invalidPresentationDefinitionData:
      return ".invalidPresentationDefinitionData"
    }
  }
}

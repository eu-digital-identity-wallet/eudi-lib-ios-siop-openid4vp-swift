import Foundation

public enum AuthorizationError: LocalizedError {
  case unsupportedResponseType(type: String)
  case missingResponseType
  case missingPresentationDefinition
  case nonHttpsPresentationDefinitionUri
  case unsupportedURLScheme
  case unsupportedResolution
  case invalidState
  case invalidResponseMode

  public var errorDescription: String? {
    switch self {
    case .unsupportedResponseType(let type):
      return ".unsupportedResponseType \(type)"
    case .missingResponseType:
      return ".invalidScopes"
    case .missingPresentationDefinition:
      return ".missingPresentationDefinition"
    case .nonHttpsPresentationDefinitionUri:
      return ".nonHttpsPresentationDefinitionUri"
    case .unsupportedURLScheme:
      return ".unsupportedURLScheme"
    case .unsupportedResolution:
      return ".unsupportedResolution"
    case .invalidState:
      return ".invalidState"
    case .invalidResponseMode:
      return ".invalidResponseMode"
    }
  }
}

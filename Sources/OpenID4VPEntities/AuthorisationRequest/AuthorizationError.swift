import Foundation

public enum AuthorizationError: LocalizedError {
  case unsupportedResponseType(type: String)
  case missingResponseType
  case missingPresentationDefinition
  case nonHttpsPresentationDefinitionUri
  case unsupportedURLScheme

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
    }
  }
}

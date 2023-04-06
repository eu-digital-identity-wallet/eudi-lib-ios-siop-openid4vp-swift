import Foundation

public enum AuthorizationError: Error {
  case unsupportedResponseType(type: String)
  case missingResponseType
  case missingPresentationDefinition
  case nonHttpsPresentationDefinitionUri
  case unsupportedURLScheme
}

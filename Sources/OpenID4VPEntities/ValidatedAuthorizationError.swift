import Foundation

public enum ValidatedAuthorizationError: Error {
  case unsupportedClientIdScheme(String?)
  case unsupportedResponseType(String?)
  case unsupportedResponseMode(String?)
  case unsupportedIdTokenType(String?)
  case invalidResponseType
  case invalidIdTokenType
  case noAuthorizationData
  case invalidAuthorizationData
  case invalidPresentationDefinition
  case invalidClientMetadata
  case missingRequiredField(String?)
}

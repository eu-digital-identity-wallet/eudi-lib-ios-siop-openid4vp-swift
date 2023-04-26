import Foundation

public enum ValidatedAuthorizationError: Error {
  case unsupportedClientIdScheme(String?)
  case unsupportedResponseType(String?)
  case invalidResponseType
  case noAuthorizationData
  case invalidAuthorizationData
  case invalidPresentationDefinition
  case invalidClientMetadata
}

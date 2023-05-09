import Foundation

public enum ValidatedAuthorizationError: LocalizedError {
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

  public var errorDescription: String? {
    switch self {
    case .unsupportedClientIdScheme(let scheme):
      return ".unsupportedClientIdScheme \(scheme ?? "")"
    case .unsupportedResponseType(let type):
      return ".unsupportedResponseType \(String(describing: type))"
    case .unsupportedResponseMode(let mode):
      return ".unsupportedResponseMode \(mode ?? "")"
    case .unsupportedIdTokenType(let type):
      return ".unsupportedIdTokenType \(type ?? "")"
    case .invalidResponseType:
      return ""
    case .invalidIdTokenType:
      return ".invalidResponseType"
    case .noAuthorizationData:
      return ".noAuthorizationData"
    case .invalidAuthorizationData:
      return ""
    case .invalidPresentationDefinition:
      return ".invalidAuthorizationData"
    case .invalidClientMetadata:
      return ".invalidClientMetadata"
    case .missingRequiredField(let field):
      return ".missingRequiredField \(field ?? "")"
    }
  }
}

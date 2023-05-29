import Foundation

/// An enumeration representing errors that can occur during authorization.
public enum AuthorizationError: LocalizedError {
  /// The response type is unsupported.
  case unsupportedResponseType(type: String)

  /// The response type is missing.
  case missingResponseType

  /// The presentation definition is missing.
  case missingPresentationDefinition

  /// The presentation definition URI is not using HTTPS.
  case nonHttpsPresentationDefinitionUri

  /// The URL scheme is unsupported.
  case unsupportedURLScheme

  /// The resolution is unsupported.
  case unsupportedResolution

  /// The state is invalid.
  case invalidState

  /// The response mode is invalid.
  case invalidResponseMode

  /// A localized description of the error.
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

import Foundation

/// An enumeration representing different types of authorization response payloads.
public enum AuthorizationResponsePayload: Encodable {
  /// An SIOP authentication response payload.
  case siopAuthenticationResponse(idToken: JWTString, state: String)

  /// An OpenID Connect 4 Verifiable Presentation authorization response payload.
  case openId4VPAuthorizationResponse(
    verifiableCredential: [JWTString],
    presentationSubmission: PresentationSubmission,
    state: String
  )

  /// An SIOP OpenID Connect 4 Verifiable Presentation authentication response payload.
  case siopOpenId4VPAuthenticationResponse(
    idToken: JWTString,
    verifiableCredential: [JWTString],
    presentationSubmission: PresentationSubmission,
    state: String
  )

  /// A failure response payload.
  case failure

  /// An invalid request response payload.
  case invalidRequest(error: AuthorizationError, state: String)

  /// A response payload indicating no consensus response data.
  case noConsensusResponseData(state: String, error: String)

  /// Coding keys for encoding the enumeration.
  enum CodingKeys: String, CodingKey {
    case siopAuthenticationResponse
    case openId4VPAuthorizationResponse
    case siopOpenId4VPAuthenticationResponse
    case failure
    case invalidRequest
    case noConsensusResponseData
    case idToken = "id_token"
    case state
    case error
  }

  /// Encodes the enumeration using the given encoder.
  public func encode(to encoder: Encoder) throws {
     var container = encoder.container(keyedBy: CodingKeys.self)

     switch self {
     case .siopAuthenticationResponse(let idToken, let state):
       try container.encode(state, forKey: .state)
       try container.encode(idToken, forKey: .idToken)
     case .noConsensusResponseData(let state, let message):
       try container.encode(state, forKey: .state)
       try container.encode(message, forKey: .error)
     default: break
     }
   }
}

import Foundation

public enum AuthorizationResponsePayload: Encodable {
  case siopAuthenticationResponse(idToken: JWTString, state: String)
  case openId4VPAuthorizationResponse(
    verifiableCredential: [JWTString],
    presentationSubmission: PresentationSubmission,
    state: String
  )
  case siopOpenId4VPAuthenticationResponse(
    idToken: JWTString,
    verifiableCredential: [JWTString],
    presentationSubmission: PresentationSubmission,
    state: String
  )
  case failure
  case invalidRequest(error: AuthorizationError, state: String)
  case noConsensusResponseData(state: String)

  enum CodingKeys: String, CodingKey {
    case siopAuthenticationResponse
    case openId4VPAuthorizationResponse
    case siopOpenId4VPAuthenticationResponse
    case failure
    case invalidRequest
    case noConsensusResponseData
  }

  public func encode(to encoder: Encoder) throws {
     var container = encoder.container(keyedBy: CodingKeys.self)

     switch self {
     case .siopAuthenticationResponse(_, let state):
       try container.encode(state, forKey: .siopAuthenticationResponse)
     default: break
     }
   }
}

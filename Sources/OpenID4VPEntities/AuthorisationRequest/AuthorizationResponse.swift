import Foundation

public enum AuthorizationResponse: Encodable {
  case directPost(url: URL, data: AuthorizationResponsePayload)
  case directPostJwt(url: URL, data: AuthorizationResponsePayload)
  case query(url: URL, data: AuthorizationResponsePayload)
  case queryJwt(url: URL, data: AuthorizationResponsePayload)
  case fragment(url: URL, data: AuthorizationResponsePayload)
  case fragmentJwt(url: URL, data: AuthorizationResponsePayload)

  enum CodingKeys: String, CodingKey {
    case directPost
    case directPostJwt
    case query
    case queryJwt
    case fragment
    case fragmentJwt
  }

  public func encode(to encoder: Encoder) throws {
     var container = encoder.container(keyedBy: CodingKeys.self)

     switch self {
     case .directPost(_, let data):
       try container.encode(data, forKey: .directPost)
     default: break
     }
   }
}

public extension AuthorizationResponse {
  init(
    resolvedRequest: ResolvedSiopOpenId4VPRequestData,
    consent: ClientConsent
  ) throws {
    switch consent {
    case .idToken(let idToken):
      switch resolvedRequest {
      case .idToken(let request):
        let payload: AuthorizationResponsePayload = .siopAuthenticationResponse(
          idToken: idToken,
          state: try request.state ?? {
            throw AuthorizationError.missingPresentationDefinition
          }()
        )
        self = try .buildAuthorizationResponse(
          responseMode: request.responseMode,
          payload: payload
        )
      default: throw AuthorizationError.unsupportedResolution
      }
    case .vpToken,
         .idAndVPToken:
      throw ValidatedAuthorizationError.unsupportedConsent
    case .negative:
      throw ValidatedAuthorizationError.negativeConsent
    }
  }
}

private extension AuthorizationResponse {
  static func buildAuthorizationResponse(
    responseMode: ResponseMode?,
    payload: AuthorizationResponsePayload
  ) throws -> AuthorizationResponse {
    guard let responseMode = responseMode else {
      throw AuthorizationError.invalidResponseMode
    }
    switch responseMode {
    case .directPost(let responseURI):
      return .directPost(url: responseURI, data: payload)
    case .directPostJWT(let responseURI):
      return .directPostJwt(url: responseURI, data: payload)
    case .query(let responseURI):
      return .query(url: responseURI, data: payload)
    case .fragment(let responseURI):
      return .fragment(url: responseURI, data: payload)
    case .none:
      throw AuthorizationError.invalidResponseMode
    }
  }
}

import Foundation

public enum AuthorizationRequest {
  case oauth2(data: ResolvedSiopOpenId4VPRequestData)
  case jwtSecuredAuthorizationRequest(request: JwtSecuredAuthorizationRequest)
}

public extension AuthorizationRequest {
  init(authorizationRequestData: AuthorizationRequestUnprocessedData?) async throws {

    guard
      let authorizationRequestData = authorizationRequestData
    else {
      throw ValidatedAuthorizationError.noAuthorizationData
    }

    if let request = authorizationRequestData.request {
      self = .jwtSecuredAuthorizationRequest(request: .passByValue(jwt: request))

    } else if let requestUri = authorizationRequestData.requestUri {
      self = .jwtSecuredAuthorizationRequest(request: .passByReference(jwtURI: requestUri))

    } else {

      let validatedAuthorizationRequestData = try ValidatedSiopOpenId4VPRequest(
        authorizationRequestData: authorizationRequestData
      )

      let resolvedSiopOpenId4VPRequestData = try await ResolvedSiopOpenId4VPRequestData(
        clientMetaDataResolver: ClientMetaDataResolver(),
        presentationDefinitionResolver: PresentationDefinitionResolver(),
        validatedAuthorizationRequest: validatedAuthorizationRequestData
      )

      self = .oauth2(data: resolvedSiopOpenId4VPRequestData)
    }
  }
}

public enum JwtSecuredAuthorizationRequest {
  case passByValue(jwt: JWTString)
  case passByReference(jwtURI: JWTURI)
}

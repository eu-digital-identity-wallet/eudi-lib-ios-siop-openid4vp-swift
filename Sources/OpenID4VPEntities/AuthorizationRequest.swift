import Foundation

enum AuthorizationRequest {
  case oauth2(data: AuthorizationRequestData)
  case jwtSecuredAuthorizationRequest(request: JwtSecuredAuthorizationRequest)
}

extension AuthorizationRequest {
  static func make(url: URL) -> Result<AuthorizationRequest, AuthorizationError> {
    .failure(.unsupportedURLScheme)
  }
}

enum JwtSecuredAuthorizationRequest {
  case passByValue(jwt: JWTString)
  case passByReference(jwtURI: JWTURI)
}

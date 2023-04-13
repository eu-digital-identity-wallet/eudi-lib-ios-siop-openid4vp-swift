import Foundation

protocol AuthorizationResponseData {
  
}

enum AuthorizationResponse {
  case directPost(url: URL, data: AuthorizationResponseData)
  case directPostJwt(url: URL, jwt: JWTString)
  case oauth2(url: URL, data: AuthorizationResponseData)
  case invalid(error: AuthorizationError)
  case failure
}

import Foundation

enum OpenId4VPAuthorization {
  case url(URL)
  case request(AuthorizationRequest)
}

protocol OpenId4VPAuthorizationEndPointProtocol {
  var response: AuthorizationResponse {get set}
  func initialize(wallet configuration: Any)
  func authorize(authorization: OpenId4VPAuthorization) -> Result<AuthorizationResponse, Error>
  func match(claims: [JSONObject]) -> Result<AuthorizationResponse, Error>
  func consent()
}

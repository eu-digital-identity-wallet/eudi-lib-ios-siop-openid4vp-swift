import Foundation

protocol OpenId4VPAuthorizationEndPointProtocol {
  func authorize(url: URL) -> AuthorizationResponse
  func authorize(auth: AuthorizationRequest) -> AuthorizationResponse
}

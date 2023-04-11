import Foundation

protocol OpenId4VPAuthorizationEndPointProtocol {
  func authorize(url: URL) async -> AuthorizationResponse
  func authorize(auth: AuthorizationRequest) async -> AuthorizationResponse
}

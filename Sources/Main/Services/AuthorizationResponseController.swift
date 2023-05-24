import Foundation

public protocol AuthorizationResponseControllerType {
  func post<T: Codable>(response: AuthorizationResponse) async throws -> T
}

public class AuthorizationResponseController {
  public let service: AuthorisationServiceType
  public let authorizationResponse: AuthorizationResponse
  public init(
    service: AuthorisationServiceType,
    authorizationResponse: AuthorizationResponse
  ) {
    self.service = service
    self.authorizationResponse = authorizationResponse
  }
  
  public func post<T: Codable>(response: AuthorizationResponse) async throws -> T {
    return try await service.post(response: response)
  }
}

import Foundation

/// A protocol for an authorization response controller.
public protocol AuthorizationResponseControllerType {
  /// Posts a response and returns a generic result.
  func post<T: Codable>(response: AuthorizationResponse) async throws -> T
}

/// An implementation of the `AuthorizationResponseControllerType` protocol.
public class AuthorizationResponseController {
  /// The authorization service used for posting responses.
  public let service: AuthorisationServiceType

  /// The authorization response to be posted.
  public let authorizationResponse: AuthorizationResponse

  /// Initializes an `AuthorizationResponseController` with the provided service and authorization response.
  public init(
    service: AuthorisationServiceType,
    authorizationResponse: AuthorizationResponse
  ) {
    self.service = service
    self.authorizationResponse = authorizationResponse
  }

  /// Posts a response and returns a generic result.
  public func post<T: Codable>(response: AuthorizationResponse) async throws -> T {
    return try await service.post(response: response)
  }
}

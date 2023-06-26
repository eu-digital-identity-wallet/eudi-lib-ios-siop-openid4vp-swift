import Foundation

/// A protocol for an authorization response controller.
public protocol DispatcherType {
  /// Dispatches a response and returns a generic result.
  func dispatch<T: Codable>(poster: Posting) async throws -> T
}

/// An implementation of the `DispatcherType` protocol.
public class Dispatcher: DispatcherType {
  /// The authorization service used for posting responses.
  public let service: AuthorisationServiceType

  /// The authorization response to be posted.
  public let authorizationResponse: AuthorizationResponse

  /// Initializes an `AuthorizationResponseController` with the provided service and authorization response.
  public init(
    service: AuthorisationServiceType = AuthorisationService(),
    authorizationResponse: AuthorizationResponse
  ) {
    self.service = service
    self.authorizationResponse = authorizationResponse
  }

  /// Posts a response and returns a generic result.
  public func dispatch<T: Codable>(
    poster: Posting = Poster()
  ) async throws -> T {
    return try await service.formPost(
      poster: poster,
      response: self.authorizationResponse
    )
  }
}

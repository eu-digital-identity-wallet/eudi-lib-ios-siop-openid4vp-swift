import Foundation

/// A protocol for an authorization response controller.
public protocol DispatcherType {
  /// Dispatches a response and returns a generic result.
  func dispatch(poster: Posting) async throws -> DispatchOutcome
}

/// An implementation of the `DispatcherType` protocol.
public actor Dispatcher: DispatcherType {
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
  public func dispatch(
    poster: Posting = Poster()
  ) async throws -> DispatchOutcome {
    let result = try await service.formCheck(
      poster: poster,
      response: self.authorizationResponse
    )

    return result == true ? .accepted(redirectURI: nil) : .rejected(reason: "")
  }
}

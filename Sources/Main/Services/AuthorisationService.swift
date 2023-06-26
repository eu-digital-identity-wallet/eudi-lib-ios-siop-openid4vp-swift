import Foundation

/// A protocol for an authorization service.
public protocol AuthorisationServiceType {
  /// Posts a response and returns a generic result.
  func formPost<T: Codable>(poster: Posting, response: AuthorizationResponse) async throws -> T
}

/// An implementation of the `AuthorisationServiceType` protocol.
public class AuthorisationService: AuthorisationServiceType {
  public init() { }

  /// Posts a response and returns a generic result.
  public func formPost<T: Codable>(
    poster: Posting = Poster(),
    response: AuthorizationResponse
  ) async throws -> T {
    switch response {
    case .directPost(let url, let data):
      let response = VerifierFormPost(
        additionalHeaders: ["Content-Type": ContentType.form.rawValue],
        url: url,
        formData: try data.toDictionary()
      )
      let result: Result<T, PostError> = await poster.post(request: response.urlRequest)
      return try result.get()
    default: throw AuthorizationError.invalidResponseMode
    }
  }
}

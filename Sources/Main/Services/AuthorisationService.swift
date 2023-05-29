import Foundation

/// A struct representing a direct POST request.
public struct DirectPost: Request {
  public typealias Response = DirectPostResponse

  /// The HTTP method for the request.
  public var method: HTTPMethod { .POST }

  /// Additional headers to include in the request.
  public var additionalHeaders: [String: String] = [:]

  /// The URL for the request.
  public var url: URL

  /// The request body as data.
  public var body: Data? {
    var formDataComponents = URLComponents()
    formDataComponents.queryItems = formData.toQueryItems()
    let formDataString = formDataComponents.query
    return formDataString?.data(using: .utf8)
  }

  /// The form data for the request.
  let formData: [String: Any]

  /// The URL request representation of the DirectPost.
  var urlRequest: URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.httpBody = body
    request.allHTTPHeaderFields = additionalHeaders
    return request
  }
}

/// A struct representing the response to a direct POST request.
public struct DirectPostResponse: Codable, Equatable { }

/// A protocol for an authorization service.
public protocol AuthorisationServiceType {
  /// Posts a response and returns a generic result.
  func post<T: Codable>(response: AuthorizationResponse) async throws -> T
}

/// An implementation of the `AuthorisationServiceType` protocol.
public class AuthorisationService: AuthorisationServiceType {
  public init() { }

  /// Posts a response and returns a generic result.
  public func post<T: Codable>(response: AuthorizationResponse) async throws -> T {
    switch response {
    case .directPost(let url, let data):
      let poster = Poster()
      let response = DirectPost(
        additionalHeaders: ["Content-Type": "application/x-www-form-urlencoded"],
        url: url,
        formData: try data.toDictionary()
      )
      let result: Result<T, PostError> = await poster.post(request: response.urlRequest)
      return try result.get()
    default: throw AuthorizationError.invalidResponseMode
    }
  }
}

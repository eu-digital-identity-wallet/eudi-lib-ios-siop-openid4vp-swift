import Foundation

/// A struct representing a form POST request.
public struct VerifierFormPost: Request {
  public typealias Response = DispatchOutcome

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

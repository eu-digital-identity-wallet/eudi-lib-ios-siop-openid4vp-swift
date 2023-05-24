import Foundation

public struct DirectPost: Request {
  public typealias Response = DirectPostResponse
  public var method: HTTPMethod { .POST }
  public var additionalHeaders: [String: String] = [:]
  public var url: URL
  public var body: Data? {
    var formDataComponents = URLComponents()
    formDataComponents.queryItems = formData.toQueryItems()
    let formDataString = formDataComponents.query
    return formDataString?.data(using: .utf8)
  }
  let formData: [String: Any]

  var urlRequest: URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.httpBody = body
    request.allHTTPHeaderFields = additionalHeaders
    return request
  }
}

public struct DirectPostResponse: Codable, Equatable { }

public protocol AuthorisationServiceType {
  func post<T: Codable>(response: AuthorizationResponse) async throws -> T
}

public class AuthorisationService: AuthorisationServiceType {
  public init() { }
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

import Foundation

public enum HTTPMethod: String {
  case GET
  case POST
  case PUT
  case DELETE
  case PATCH
}

public protocol Request {
  associatedtype Response

  var method: HTTPMethod { get }
  var url: URL { get }
  var additionalHeaders: [String: String] { get }
  var body: Data? { get }
}

extension Request {
  public var method: HTTPMethod { .GET }
  public var body: Data? { nil }
}

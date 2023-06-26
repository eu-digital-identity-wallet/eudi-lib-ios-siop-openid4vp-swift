import Foundation

public enum PostError: Error {
  case invalidUrl
  case networkError(Error)

  /**
   Provides a localized description of the post error.

   - Returns: A string describing the post error.
   */
  public var localizedDescription: String {
    switch self {
    case .invalidUrl:
      return "Invalid URL"
    case .networkError(let error):
      return "Network Error: \(error.localizedDescription)"
    }
  }
}

public protocol Posting {
  /**
   Performs a POST request with the provided URLRequest.

   - Parameters:
      - request: The URLRequest to be used for the POST request.

   - Returns: A Result type with the response data or an error.
   */
  func post<Response: Codable>(request: URLRequest) async -> Result<Response, PostError>
}

public struct Poster: Posting {
  /**
   Initializes a Poster instance.
   */
  public init() {}

  /**
   Performs a POST request with the provided URLRequest.

   - Parameters:
      - request: The URLRequest to be used for the POST request.

   - Returns: A Result type with the response data or an error.
   */
  public func post<Response: Codable>(request: URLRequest) async -> Result<Response, PostError> {
    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      if let stringData = String(data: data, encoding: .utf8) {
        print("*** post response string \(stringData)")
      } else {

        print("*** failed to convert data to string")
      }

      let object = try JSONDecoder().decode(Response.self, from: data)
      print("*** post response object\(object)")

      return .success(object)
    } catch let error as NSError {
      if error.domain == NSURLErrorDomain {
        return .failure(.networkError(error))
      } else {
        return .failure(.networkError(error))
      }
    } catch {
      return .failure(.networkError(error))
    }
  }
}

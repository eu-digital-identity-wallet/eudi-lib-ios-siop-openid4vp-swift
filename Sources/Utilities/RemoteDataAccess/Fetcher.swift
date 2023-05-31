import Foundation

public enum FetchError: LocalizedError {
  case invalidUrl
  case networkError(Error)
  case invalidResponse
  case decodingError(Error)

  /**
   Provides a localized description of the fetch error.

   - Returns: A string describing the fetch error.
   */
  public var errorDescription: String? {
    switch self {
    case .invalidUrl:
      return ".invalidUrl"
    case .networkError(let error):
      return ".networkError \(error.localizedDescription)"
    case .invalidResponse:
      return ".invalidResponse"
    case .decodingError(let error):
      return ".decodingError \(error.localizedDescription)"
    }
  }
}

public protocol Fetching {
  associatedtype Element: Codable

  /**
    Fetches data from the provided URL.

    - Parameters:
       - session: The URLSession to use for fetching the data.
       - url: The URL from which to fetch the data.

    - Returns: A `Result` type with the fetched data or an error.
   */
  func fetch(session: URLSession, url: URL) async -> Result<Element, FetchError>
}

public struct Fetcher<Element: Codable>: Fetching {
  @Injected var reporter: Reporting

  /**
   Initializes a Fetcher instance.
   */
  public init() {}

  /**
   Fetches data from the provided URL.

   - Parameters:
      - url: The URL from which to fetch the data.

   - Returns: A Result type with the fetched data or an error.
   */
  public func fetch(session: URLSession = URLSession.shared, url: URL) async -> Result<Element, FetchError> {
    do {
      let (data, response) = try await URLSession.shared.data(from: url)
      let object = try JSONDecoder().decode(Element.self, from: data)

      if let httpResponse = response as? HTTPURLResponse {
        reporter.debug("Status code: \(httpResponse.statusCode)")
      }

      return .success(object)
    } catch let error as NSError {
      if error.domain == NSURLErrorDomain {
        return .failure(.networkError(error))
      } else {
        return .failure(.decodingError(error))
      }
    } catch {
      return .failure(.decodingError(error))
    }
  }
}

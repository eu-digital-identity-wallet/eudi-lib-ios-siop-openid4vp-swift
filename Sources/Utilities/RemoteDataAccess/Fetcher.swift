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
      let delegate = SelfSignedSessionDelegate()
      let configuration = URLSessionConfiguration.default
      let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
      let (data, response) = try await session.data(from: url)
      let object = try JSONDecoder().decode(Element.self, from: data)

      if let httpResponse = response as? HTTPURLResponse {
        reporter.info("Status code: \(httpResponse.statusCode)")
      }

      return .success(object)
    } catch let error as NSError {
      reporter.debug("error: \(error.localizedDescription)")
      if error.domain == NSURLErrorDomain {
        return .failure(.networkError(error))
      } else {
        return .failure(.decodingError(error))
      }
    } catch {
      reporter.debug("error: \(error.localizedDescription)")
      return .failure(.decodingError(error))
    }
  }

  public func fetchString(url: URL) async -> Result<String, FetchError> {
    do {
      let delegate = SelfSignedSessionDelegate()
      let configuration = URLSessionConfiguration.default
      let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)

      let (data, _) = try await session.data(from: url)
      if let string = String(data: data, encoding: .utf8) {
        return .success(string)

      } else {

        let error = NSError(
          domain: "com.example.networking",
          code: 0,
          userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to string"]
        )

        return .failure(.decodingError(error))
      }
    } catch let error as NSError {
      reporter.debug("error: \(error.localizedDescription)")
      if error.domain == NSURLErrorDomain {
        return .failure(.networkError(error))
      } else {
        return .failure(.decodingError(error))
      }
    } catch {
      reporter.debug("error: \(error.localizedDescription)")
      return .failure(.decodingError(error))
    }
  }
}

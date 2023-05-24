import Foundation

public enum FetchError: LocalizedError {
  case invalidUrl
  case networkError(Error)
  case invalidResponse
  case decodingError(Error)

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
  func fetch(url: URL) async -> Result<Element, FetchError>
}

public struct Fetcher<Element: Codable>: Fetching {

  @Injected var reporter: Reporting

  public init() {}
  public func fetch(url: URL) async -> Result<Element, FetchError> {
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

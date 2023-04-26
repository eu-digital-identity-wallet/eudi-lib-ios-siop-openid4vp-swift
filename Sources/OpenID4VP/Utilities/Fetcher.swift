import Foundation

public enum FetchError: Error {
  case invalidUrl
  case networkError(Error)
  case invalidResponse
  case decodingError(Error)
}

public protocol Fetching {
  associatedtype Element: Codable
  func fetch(url: URL) async -> Result<Element, FetchError>
}

public struct Fetcher<Element: Codable>: Fetching {
  public init() {}
  public func fetch(url: URL) async -> Result<Element, FetchError> {
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      let object = try JSONDecoder().decode(Element.self, from: data)
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

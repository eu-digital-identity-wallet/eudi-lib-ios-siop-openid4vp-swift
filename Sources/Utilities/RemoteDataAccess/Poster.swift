import Foundation

public enum PostError: Error {
  case invalidUrl
  case networkError(Error)
}

public protocol Posting {
  func post<Response: Codable>(request: URLRequest) async -> Result<Response, PostError>
}

public struct Poster: Posting {
  public init() {}
  public func post<Response: Codable>(request: URLRequest) async -> Result<Response, PostError> {
    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      let object = try JSONDecoder().decode(Response.self, from: data)
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

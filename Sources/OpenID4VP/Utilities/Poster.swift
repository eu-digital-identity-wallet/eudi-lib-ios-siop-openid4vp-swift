import Foundation

public enum PostError: Error {
  case invalidUrl
  case networkError(Error)
}

public protocol Posting {
  func post(request: URLRequest) async -> Result<Bool, PostError>
}

public struct Poster: Posting {
  public init() {}
  public func post(request: URLRequest) async -> Result<Bool, PostError> {
    do {
      let (_, _) = try await URLSession.shared.data(for: request)
      return .success(true)
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

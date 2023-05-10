import Foundation

public enum ParserError: LocalizedError {
  case notFound
  case invalidData
  case decodingFailure(String)

  public var errorDescription: String? {
    switch self {
    case .notFound:
      return ".notFound"
    case .invalidData:
      return ".invalidData"
    case .decodingFailure(let failure):
      return ".decodingFailure \(failure)"
    }
  }
}

public protocol ParserProtocol {
  func decode<T: Codable>(path: String, type: String) -> Result<T, ParserError>
  func decode<T: Codable>(json: String) -> Result<T, ParserError>
}

public class Parser: ParserProtocol {
  public func decode<T: Codable>(json: String) -> Result<T, ParserError> {
    guard
      let data = json.data(using: .utf8)
    else {
      return .failure(.invalidData)
    }

    let decoder = JSONDecoder()

    do {
       let presentationDefinition = try decoder.decode(T.self, from: data)
      return .success(presentationDefinition)

    } catch {
      return .failure(.decodingFailure(error.localizedDescription))
    }
  }

  public func decode<T: Codable>(path: String, type: String) -> Result<T, ParserError> {

    guard
      let path = Bundle.module.path(forResource: path, ofType: type)
    else {
      return .failure(.notFound)
    }

    let url = URL(fileURLWithPath: path)

    guard
      let data = try? Data(contentsOf: url)
    else {
      return .failure(.invalidData)
    }

    let decoder = JSONDecoder()

    do {
      let object = try decoder.decode(T.self, from: data)
      return .success(object)

    } catch {
      return .failure(.decodingFailure(error.localizedDescription))
    }
  }
}

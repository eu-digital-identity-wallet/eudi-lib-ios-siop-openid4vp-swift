import Foundation

public enum JSONParseError: LocalizedError {
  case fileNotFound(filename: String)
  case dataInitialisation(Error)
  case jsonSerialization(Error)
  case mappingFail(value: Any, toType: Any)
  case invalidJSON
  case invalidJWT
  case notSupportedOperation

  public var errorDescription: String? {
    switch self {
    case .fileNotFound(let filename):
      return ".fileNotFound \(filename)"
    case .dataInitialisation(let error):
      return ".dataInitialisation \(error.localizedDescription)"
    case .jsonSerialization(let error):
      return ".jsonSerialization \(error.localizedDescription)"
    case .mappingFail(let value, let toType):
      return ".mappingFail from: \(value) to: \(toType)"
    case .invalidJSON:
      return ".invalidJSON"
    case .invalidJWT:
      return ".invalidJWT"
    case .notSupportedOperation:
      return ".notSupportedOperation"
    }
  }
}

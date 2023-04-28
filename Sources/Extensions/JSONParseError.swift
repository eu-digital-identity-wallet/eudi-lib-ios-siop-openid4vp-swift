import Foundation

public enum JSONParseError: Error {
  case fileNotFound(filename: String)
  case dataInitialisation(Error)
  case jsonSerialization(Error)
  case mappingFail(value: Any, toType: Any)
  case invalidJSON
}

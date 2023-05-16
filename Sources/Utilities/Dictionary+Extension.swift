import Foundation

public extension Dictionary {
  func filterValues(_ isIncluded: (Value) -> Bool) -> [Key: Value] {
    return filter { _, value in
      isIncluded(value)
    }
  }
}

public extension Dictionary where Key == String, Value == Any {

  static func from(localJSONfile name: String) -> Result<Self, JSONParseError> {
    let fileType = "json"
    guard let path = Bundle.module.path(forResource: name, ofType: fileType) else {
      return .failure(.fileNotFound(filename: name))
    }
    return from(JSONfile: URL(fileURLWithPath: path))
  }
}

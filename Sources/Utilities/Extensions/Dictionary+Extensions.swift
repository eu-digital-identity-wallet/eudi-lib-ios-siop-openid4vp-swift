import Foundation

public extension Dictionary where Key == String, Value == Any {
  // Creates a dictionary from a JSON file in the specified bundle
  static func from(bundle name: String) -> Result<Self, JSONParseError> {
    let fileType = "json"
    guard let path = Bundle.module.path(forResource: name, ofType: fileType) else {
      return .failure(.fileNotFound(filename: name))
    }
    return from(JSONfile: URL(fileURLWithPath: path))
  }

  // Converts the dictionary to an array of URLQueryItem objects
  func toQueryItems() -> [URLQueryItem] {
    var queryItems: [URLQueryItem] = []
    for (key, value) in self {
      if let stringValue = value as? String {
        queryItems.append(URLQueryItem(name: key, value: stringValue))
      } else if let numberValue = value as? NSNumber {
        queryItems.append(URLQueryItem(name: key, value: numberValue.stringValue))
      } else if let arrayValue = value as? [Any] {
        let arrayQueryItems = arrayValue.compactMap { (item) -> URLQueryItem? in
          guard let stringValue = item as? String else { return nil }
          return URLQueryItem(name: key, value: stringValue)
        }
        queryItems.append(contentsOf: arrayQueryItems)
      }
    }
    return queryItems
  }
}

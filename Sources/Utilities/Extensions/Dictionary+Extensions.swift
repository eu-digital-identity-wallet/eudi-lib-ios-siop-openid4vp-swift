import Foundation

/**
Extension to `Dictionary` where both the `Key` and `Value` conform to `Encodable`.

This extension adds a `toJSONData()` method that attempts to convert the dictionary
to JSON data using `JSONSerialization`.

- Returns: The JSON `Data` if the conversion is successful; otherwise, nil.

- Note: This function will fail and return nil if the dictionary contains keys or values that aren't encodable.
*/
public extension Dictionary where Key: Encodable {
  func toJSONData() -> Data? {
    do {
      return try JSONSerialization.data(withJSONObject: self, options: [])
    } catch {
      return nil
    }
  }

  func toThrowingJSONData() throws -> Data {
    return try JSONSerialization.data(withJSONObject: self, options: [])
  }
}

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

/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import Foundation

/**
 Extension to `Dictionary` where both the `Key` and `Value` conform to `Encodable`.
 
 This extension adds a `toJSONData()` method that attempts to convert the dictionary
 to JSON data using `JSONSerialization`.
 
 - Returns: The JSON `Data` if the conversion is successful; otherwise, nil.
 
 - Note: This function will fail and return nil if the dictionary contains keys or values that aren't encodable.
 */
public extension Dictionary where Key: Encodable {
  /// Converts the dictionary to Data and decodes it into a Codable object.
  /// - Parameter type: The Codable type to decode into.
  /// - Returns: A decoded object of the specified Codable type, or `nil` if the operation fails.
  func decode<T: Decodable>(to type: T.Type) -> T? {
    do {
      // Convert the dictionary to Data using JSONSerialization
      let data = try JSONSerialization.data(withJSONObject: self, options: [])

      // Decode the data into the specified Codable type
      let decodedObject = try JSONDecoder().decode(T.self, from: data)
      return decodedObject
    } catch {
      print("Failed to decode: \(error.localizedDescription)")
      return nil
    }
  }

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
      } else if let dictionaryValue = value as? [String: Any] {
        let dictionaryQueryItems = dictionaryValue.toQueryItems()
        queryItems.append(contentsOf: dictionaryQueryItems.map { item in
          URLQueryItem(name: "\(key)[\(item.name)]", value: item.value)
        })
      }
    }
    return queryItems
  }

  func getValue<T: Codable>(
    for key: String,
    error: LocalizedError
  ) throws -> T {
    guard let value = self[key] as? T else {
      throw error
    }
    return value
  }
}

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

internal enum DictionaryError: LocalizedError {
  case nilValue

  var errorDescription: String? {
    switch self {
    case .nilValue:
      return ".nilValue"
    }
  }
}

public func getStringValue(from metaData: [String: Any], for key: String) throws -> String {
  guard let value = metaData[key] as? String else {
    throw DictionaryError.nilValue
  }
  return value
}

public func getStringArrayValue(from metaData: [String: Any], for key: String) throws -> [String] {
    guard let value = metaData[key] as? [String] else {
        throw DictionaryError.nilValue
    }
    return value
}

public func == (lhs: [String: Any], rhs: [String: Any]) -> Bool {
    return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}

public extension Dictionary where Key == String, Value == Any {

  var jsonData: Data? {
    return try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
  }

  func toJSONString() -> String? {
    if let jsonData = jsonData {
      let jsonString = String(data: jsonData, encoding: .utf8)
      return jsonString
    }
    return nil
  }

  static func from(JSONfile url: URL) -> Result<Self, JSONParseError> {
    let data: Data
    do {
      data = try Data(contentsOf: url)
    } catch let error {
      return .failure(.dataInitialisation(error))
    }

    let jsonObject: Any
    do {
      jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
    } catch let error {
      return .failure(.jsonSerialization(error))
    }

    guard let jsonResult = jsonObject as? Self else {
      return .failure(.mappingFail(
        value: String(describing: jsonObject),
        toType: String(describing: Self.Type.self)
      ))
    }

    return .success(jsonResult)
  }
}

import Foundation

internal enum DictionaryError: Error {
    case nilValue
}

internal func getValue<T>(_ key: String, in dictionary: [String: T]) throws -> T {
    guard let value = dictionary[key] else {
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
      return .failure(.mappingFail(value: jsonObject, toType: Self.Type.self))
    }

    return .success(jsonResult)
  }
}

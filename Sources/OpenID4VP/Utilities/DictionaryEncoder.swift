import Foundation

class DictionaryEncoder {

  private let encoder = JSONEncoder()

  var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy {
    get { return encoder.dateEncodingStrategy }
    set { encoder.dateEncodingStrategy = newValue }
  }

  var dataEncodingStrategy: JSONEncoder.DataEncodingStrategy {
    get { return encoder.dataEncodingStrategy }
    set { encoder.dataEncodingStrategy = newValue }
  }

  var nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy {
    get { return encoder.nonConformingFloatEncodingStrategy }
    set { encoder.nonConformingFloatEncodingStrategy = newValue }
  }

  var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy {
    get { return encoder.keyEncodingStrategy }
    set { encoder.keyEncodingStrategy = newValue }
  }

  func encode<T>(_ value: T) throws -> [String: Any] where T: Encodable {
    let data = try encoder.encode(value)
    return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] ?? [:]
  }
}

import Foundation

public class DictionaryEncoder {

  private let encoder = JSONEncoder()

  public init() {
  }

  public var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy {
    get { return encoder.dateEncodingStrategy }
    set { encoder.dateEncodingStrategy = newValue }
  }

  public var dataEncodingStrategy: JSONEncoder.DataEncodingStrategy {
    get { return encoder.dataEncodingStrategy }
    set { encoder.dataEncodingStrategy = newValue }
  }

  public var nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy {
    get { return encoder.nonConformingFloatEncodingStrategy }
    set { encoder.nonConformingFloatEncodingStrategy = newValue }
  }

  public var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy {
    get { return encoder.keyEncodingStrategy }
    set { encoder.keyEncodingStrategy = newValue }
  }

  public func encode<T>(_ value: T) throws -> [String: Any] where T: Encodable {
    let data = try encoder.encode(value)
    return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] ?? [:]
  }
}

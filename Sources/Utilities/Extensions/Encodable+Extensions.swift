import Foundation

extension Encodable {
  func toDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(
      with: data,
      options: .allowFragments
    ) as? [String: Any] else {
      throw NSError(
        domain: "ConversionError",
        code: 0,
        userInfo: [NSLocalizedDescriptionKey: "Failed to convert Codable object to dictionary."]
      )
    }
    return dictionary
  }
}

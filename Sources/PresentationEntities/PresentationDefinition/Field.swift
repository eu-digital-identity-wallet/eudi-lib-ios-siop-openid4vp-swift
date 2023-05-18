import Foundation

public struct Field: Codable, Hashable {
  public let paths: [String]
  public let filter: JSONObject?
  public let purpose: String?
  public let intentToRetain: Bool?
  public let optional: Bool?

  enum CodingKeys: String, CodingKey {
    case path = "path"
    case filter, purpose, optional
    case intentToRetain = "intent_to_retain"
  }

  public init(
    paths: [String],
    filter: JSONObject?,
    purpose: String?,
    intentToRetain: Bool?,
    optional: Bool?) {
      self.paths = paths
      self.filter = filter
      self.purpose = purpose
      self.intentToRetain = intentToRetain
      self.optional = optional
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    paths = try container.decode([String].self, forKey: .path)
    filter = try? container.decode(JSONObject.self, forKey: .filter)
    purpose = try? container.decode(String.self, forKey: .purpose)
    intentToRetain = try? container.decode(Bool.self, forKey: .intentToRetain)
    optional = try? container.decode(Bool.self, forKey: .optional)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try? container.encode(paths, forKey: .path)
    try? container.encode(filter, forKey: .filter)
    try? container.encode(purpose, forKey: .purpose)
    try? container.encode(intentToRetain, forKey: .intentToRetain)
    try? container.encode(optional, forKey: .optional)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(paths)
    if let filter = filter {
      for (key, value) in filter {
        hasher.combine(key)
        if let value = value as? String {
          hasher.combine(value)
        }
      }
    }
    hasher.combine(purpose)
    hasher.combine(intentToRetain)
  }

  public static func == (lhs: Field, rhs: Field) -> Bool {
    return lhs.paths == rhs.paths &&
           lhs.purpose == rhs.purpose &&
           lhs.intentToRetain == rhs.intentToRetain &&
           lhs.filter ?? JSONObject() == rhs.filter ?? JSONObject()
  }
}

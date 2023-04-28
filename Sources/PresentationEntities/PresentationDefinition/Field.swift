import Foundation

public struct Field: Codable {

  public let paths: [String]
  public let filter: JSONObject?
  public let purpose: String?
  public let intentToRetain: Bool?

  enum CodingKeys: String, CodingKey {
    case path = "path"
    case filter, purpose
    case intentToRetain = "intent_to_retain"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    paths = try container.decode([String].self, forKey: .path)
    filter = try? container.decode(JSONObject.self, forKey: .filter)
    purpose = try? container.decode(String.self, forKey: .purpose)
    intentToRetain = try? container.decode(Bool.self, forKey: .filter)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try? container.encode(paths, forKey: .path)
    try? container.encode(filter, forKey: .filter)
    try? container.encode(purpose, forKey: .purpose)
    try? container.encode(intentToRetain, forKey: .intentToRetain)
  }
}

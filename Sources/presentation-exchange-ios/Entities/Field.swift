import Foundation

struct Field: Codable {

  let path: [String]
  let filter: JSONObject?
  let purpose: String?
  let intentToRetain: Bool?

  enum CodingKeys: String, CodingKey {
    case path, filter, purpose
    case intentToRetain = "intent_to_retain"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    path = try container.decode([String].self, forKey: .path)
    filter = try container.decode(JSONObject.self, forKey: .filter)
    purpose = try? container.decode(String.self, forKey: .purpose)
    intentToRetain = try? container.decode(Bool.self, forKey: .filter)
  }
      
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try? container.encode(path, forKey: .path)
    try? container.encode(filter, forKey: .filter)
    try? container.encode(purpose, forKey: .purpose)
    try? container.encode(intentToRetain, forKey: .intentToRetain)
  }
}

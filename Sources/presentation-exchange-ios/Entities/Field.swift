import Foundation

struct Field: Codable, Equatable {
  let path: [String]
  let filter: Filter
  let purpose: String?
  let intentToRetain: Bool?

  enum CodingKeys: String, CodingKey {
    case path, filter, purpose
    case intentToRetain = "intent_to_retain"
  }
}

import Foundation

struct Constraints: Codable {
  public let fields: [Field]
  
  enum CodingKeys: String, CodingKey {
    case fields
  }
}

import Foundation

struct Constraints: Codable, Equatable {
  public let fields: [Field]
  
  enum CodingKeys: String, CodingKey {
    case fields
  }
}

import Foundation

public struct Constraints: Codable {
  public let fields: [Field]

  enum CodingKeys: String, CodingKey {
    case fields
  }

  public init(fields: [Field]) {
    self.fields = fields
  }
}

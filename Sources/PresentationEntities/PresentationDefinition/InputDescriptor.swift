import Foundation

public struct InputDescriptor: Codable {
  public let id: InputDescriptorId
  public let name: Name?
  public let purpose: Purpose?
  public let formatContainer: FormatContainer?
  public let constraints: Constraints
  public let groups: [Group]?

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case purpose
    case formatContainer = "format"
    case constraints
    case groups = "group"
  }
}

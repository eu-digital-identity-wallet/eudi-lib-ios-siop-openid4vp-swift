import Foundation

public struct InputDescriptor: Codable {
  public let id: InputDescriptorId
  public let name: Name?
  public let purpose: Purpose?
  public let format: Format?
  public let constraints: Constraints
  public let groups: [Group]?
  
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case purpose
    case format
    case constraints
    case groups = "group"
  }
}

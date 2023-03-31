import Foundation

struct InputDescriptor: Codable {
  let id: InputDescriptorId
  let name: Name?
  let purpose: Purpose?
  let format: Format?
  let constraints: Constraints
  let groups: [Group]
  
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case purpose
    case format
    case constraints
    case groups = "group"
  }
}

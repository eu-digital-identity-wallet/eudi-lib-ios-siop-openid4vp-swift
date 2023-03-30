import Foundation

/*
 Based on https://identity.foundation/presentation-exchange/
 */
struct PresentationDefinitionContainer: Codable, Equatable {
  let definition: PresentationDefinition
  
  enum CodingKeys: String, CodingKey {
    case definition = "presentation_definition"
  }
}

struct PresentationDefinition: Codable, Equatable {
  
  let id: String
  let name: Name?
  let purpose: Purpose?
  let format: Format?
  let inputDescriptors: [InputDescriptor]
  
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case purpose
    case format
    case inputDescriptors = "input_descriptors"
  }
}

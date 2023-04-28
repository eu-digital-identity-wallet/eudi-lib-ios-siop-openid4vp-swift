import Foundation

/*
 Based on https://identity.foundation/presentation-exchange/
 */
public struct PresentationDefinitionContainer: Codable {
  let comment: String?
  let definition: PresentationDefinition

  enum CodingKeys: String, CodingKey {
    case comment
    case definition = "presentation_definition"
  }

  public init(
    comment: String,
    definition: PresentationDefinition
  ) {
    self.comment = comment
    self.definition = definition
  }
}

public struct PresentationDefinition: Codable {

  public let id: String
  public let name: Name?
  public let purpose: Purpose?
  public let format: Format?
  public let inputDescriptors: [InputDescriptor]

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case purpose
    case format
    case inputDescriptors = "input_descriptors"
  }
}

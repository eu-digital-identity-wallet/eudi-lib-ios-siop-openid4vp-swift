import Foundation

/*
 Based on https://identity.foundation/presentation-exchange/
 */
public struct PresentationDefinitionContainer: Codable {
  public  let comment: String?
  public let definition: PresentationDefinition

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
  public let formatContainer: FormatContainer?
  public let inputDescriptors: [InputDescriptor]
  public let submissionRequirements: [SubmissionRequirement]?

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case purpose
    case formatContainer = "format"
    case inputDescriptors = "input_descriptors"
    case submissionRequirements = "submission_requirements"
  }

  public init(
    id: String,
    name: Name?,
    purpose: Purpose?,
    formatContainer: FormatContainer?,
    inputDescriptors: [InputDescriptor],
    submissionRequirements: [SubmissionRequirement]?) {
      self.id = id
      self.name = name
      self.purpose = purpose
      self.formatContainer = formatContainer
      self.inputDescriptors = inputDescriptors
      self.submissionRequirements = submissionRequirements
  }
}

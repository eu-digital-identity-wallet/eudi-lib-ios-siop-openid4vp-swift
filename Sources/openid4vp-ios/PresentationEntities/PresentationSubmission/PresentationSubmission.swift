import Foundation

/**
 Based on https://identity.foundation/presentation-exchange/
 */
public struct PresentationSubmissionContainer: Codable {
  let submission: PresentationSubmission

  enum CodingKeys: String, CodingKey {
    case submission = "presentation_submission"
  }

  public init(
    submission: PresentationSubmission
  ) {
    self.submission = submission
  }
}

public struct PresentationSubmission: Codable {
  let id: String
  let definitionID: String
  let descriptorMap: [DescriptorMap]

  enum CodingKeys: String, CodingKey {
    case id
    case definitionID = "definition_id"
    case descriptorMap = "descriptor_map"
  }

  public init(
    id: String,
    definitionID: String,
    descriptorMap: [DescriptorMap]
  ) {
    self.id = id
    self.definitionID = definitionID
    self.descriptorMap = descriptorMap
  }
}

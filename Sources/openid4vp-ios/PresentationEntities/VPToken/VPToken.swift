import Foundation

public struct VpTokenContainer: Codable {
  public let vpToken: VpToken

  enum CodingKeys: String, CodingKey {
    case vpToken = "vp_token"
  }
  
  public init(vpToken: VpToken) {
    self.vpToken = vpToken
  }
}

public struct VpToken: Codable {
  public let presentationDefinition: PresentationDefinition

  enum CodingKeys: String, CodingKey {
    case presentationDefinition = "presentation_definition"
  }
  
  public init(presentationDefinition: PresentationDefinition) {
    self.presentationDefinition = presentationDefinition
  }
}

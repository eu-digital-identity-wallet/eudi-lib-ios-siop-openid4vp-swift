import Foundation

public struct WalletOpenId4VPConfiguration {
  public let subjectSyntaxTypesSupported: [SubjectSyntaxType]
  public let preferredSubjectSyntaxType: SubjectSyntaxType
  public let decentralizedIdentifier: String
  public let idTokenTTL: TimeInterval
  public let presentationDefinitionUriSupported: Bool
  public let supportedClientIdScheme: ClientIdScheme
  public let vpFormatsSupported: [ClaimFormat]
  public let knownPresentationDefinitionsPerScope: [String: PresentationDefinition]

  init(
    subjectSyntaxTypesSupported: [SubjectSyntaxType],
    preferredSubjectSyntaxType: SubjectSyntaxType,
    decentralizedIdentifier: String,
    idTokenTTL: TimeInterval = 600.0,
    presentationDefinitionUriSupported: Bool = false,
    supportedClientIdScheme: ClientIdScheme,
    vpFormatsSupported: [ClaimFormat],
    knownPresentationDefinitionsPerScope: [String: PresentationDefinition] = [:]
  ) {
    self.subjectSyntaxTypesSupported = subjectSyntaxTypesSupported
    self.preferredSubjectSyntaxType = preferredSubjectSyntaxType
    self.decentralizedIdentifier = decentralizedIdentifier
    self.idTokenTTL = idTokenTTL
    self.presentationDefinitionUriSupported = presentationDefinitionUriSupported
    self.supportedClientIdScheme = supportedClientIdScheme
    self.vpFormatsSupported = vpFormatsSupported
    self.knownPresentationDefinitionsPerScope = knownPresentationDefinitionsPerScope
  }
}

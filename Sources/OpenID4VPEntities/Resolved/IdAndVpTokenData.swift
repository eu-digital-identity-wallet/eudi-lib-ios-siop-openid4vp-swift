import Foundation

extension ResolvedSiopOpenId4VPRequestData {
  public struct IdAndVpTokenData {
    let idTokenType: [IdTokenType]
    let presentationDefinition: PresentationDefinition
    let clientMetaData: ClientMetaData?
    let clientId: String
    let nonce: String
    let responseMode: ResponseMode?
    let state: String?
    let scope: Scope?

    public init(
      idTokenType: [IdTokenType],
      presentationDefinition: PresentationDefinition,
      clientMetaData: ClientMetaData?,
      clientId: String,
      nonce: String,
      responseMode: ResponseMode?,
      state: String?,
      scope: Scope?
    ) {
      self.idTokenType = idTokenType
      self.presentationDefinition = presentationDefinition
      self.clientMetaData = clientMetaData
      self.clientId = clientId
      self.nonce = nonce
      self.responseMode = responseMode
      self.state = state
      self.scope = scope
    }
  }
}

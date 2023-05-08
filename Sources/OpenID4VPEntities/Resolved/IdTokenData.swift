import Foundation

extension ResolvedSiopOpenId4VPRequestData {
  public struct IdTokenData {
    let idTokenType: [IdTokenType]
    let clientMetaData: ClientMetaData
    let clientId: String
    let nonce: String
    let responseMode: ResponseMode
    let state: String?
    let scope: Scope?
    
    public init(
      idTokenType: [IdTokenType],
      clientMetaData: ClientMetaData,
      clientId: String,
      nonce: String,
      responseMode: ResponseMode,
      state: String?,
      scope: Scope?
    ) {
      self.idTokenType = idTokenType
      self.clientMetaData = clientMetaData
      self.clientId = clientId
      self.nonce = nonce
      self.responseMode = responseMode
      self.state = state
      self.scope = scope
    }
  }
}

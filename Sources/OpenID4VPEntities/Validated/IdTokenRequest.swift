import Foundation

extension ValidatedSiopOpenId4VPRequest {
  public struct IdTokenRequest {
    let idTokenType: [IdTokenType]
    let clientMetaDataSource: ClientMetaDataSource?
    let clientIdScheme: ClientIdScheme?
    let clientId: String
    let nonce: String
    let scope: Scope?
    let responseMode: ResponseMode
    let state: String?

    public init(
      idTokenType: [IdTokenType],
      clientMetaDataSource: ClientMetaDataSource?,
      clientIdScheme: ClientIdScheme?,
      clientId: String,
      nonce: String,
      scope: Scope?,
      responseMode: ResponseMode,
      state: String?
    ) {
      self.idTokenType = idTokenType
      self.clientMetaDataSource = clientMetaDataSource
      self.clientIdScheme = clientIdScheme
      self.clientId = clientId
      self.nonce = nonce
      self.scope = scope
      self.responseMode = responseMode
      self.state = state
    }
  }
}

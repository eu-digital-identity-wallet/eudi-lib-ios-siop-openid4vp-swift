import Foundation

extension ResolvedSiopOpenId4VPRequestData {
  /// A structure representing the data related to the ID token.
  public struct IdTokenData {
    let idTokenType: IdTokenType
    let clientMetaData: ClientMetaData?
    let clientId: String
    let nonce: String
    let responseMode: ResponseMode?
    let state: String?
    let scope: Scope?

    /// Initializes the `IdTokenData` structure with the provided values.
    /// - Parameters:
    ///   - idTokenType: The type of the ID token.
    ///   - clientMetaData: The client metadata.
    ///   - clientId: The client ID.
    ///   - nonce: The nonce.
    ///   - responseMode: The response mode.
    ///   - state: The state.
    ///   - scope: The scope.
    public init(
      idTokenType: IdTokenType,
      clientMetaData: ClientMetaData?,
      clientId: String,
      nonce: String,
      responseMode: ResponseMode?,
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

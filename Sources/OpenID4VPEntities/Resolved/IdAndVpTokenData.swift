import Foundation
import PresentationExchange

extension ResolvedRequestData {
  /// A structure representing the data related to ID token and verifiable presentation (VP) token.
  public struct IdAndVpTokenData {
    let idTokenType: IdTokenType
    let presentationDefinition: PresentationDefinition
    let clientMetaData: ClientMetaData?
    let clientId: String
    let nonce: String
    let responseMode: ResponseMode?
    let state: String?
    let scope: Scope?

    /// Initializes the `IdAndVpTokenData` structure with the provided values.
    /// - Parameters:
    ///   - idTokenType: The type of the ID token.
    ///   - presentationDefinition: The presentation definition.
    ///   - clientMetaData: The client metadata.
    ///   - clientId: The client ID.
    ///   - nonce: The nonce.
    ///   - responseMode: The response mode.
    ///   - state: The state.
    ///   - scope: The scope.
    public init(
      idTokenType: IdTokenType,
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

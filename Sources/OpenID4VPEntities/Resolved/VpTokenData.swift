import Foundation
import PresentationExchange

extension ResolvedSiopOpenId4VPRequestData {
  public struct VpTokenData {
    let presentationDefinition: PresentationDefinition
    let clientMetaData: ClientMetaData?
    let clientId: String
    let nonce: String
    let responseMode: ResponseMode?
    let state: String?

    /// Initializes a `VpTokenData` instance with the provided parameters.
    ///
    /// - Parameters:
    ///   - presentationDefinition: The presentation definition.
    ///   - clientMetaData: The client metadata.
    ///   - clientId: The client ID.
    ///   - nonce: The nonce value.
    ///   - responseMode: The response mode.
    ///   - state: The state value.
    public init(
      presentationDefinition: PresentationDefinition,
      clientMetaData: ClientMetaData?,
      clientId: String,
      nonce: String,
      responseMode: ResponseMode?,
      state: String?
    ) {
      self.presentationDefinition = presentationDefinition
      self.clientMetaData = clientMetaData
      self.clientId = clientId
      self.nonce = nonce
      self.responseMode = responseMode
      self.state = state
    }
  }
}

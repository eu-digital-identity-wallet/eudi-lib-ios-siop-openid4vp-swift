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

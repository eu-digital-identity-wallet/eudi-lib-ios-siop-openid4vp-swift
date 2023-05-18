import Foundation
import PresentationExchange

extension ValidatedSiopOpenId4VPRequest {
  public struct VpTokenRequest {
    let presentationDefinitionSource: PresentationDefinitionSource
    let clientMetaDataSource: ClientMetaDataSource?
    let clientIdScheme: ClientIdScheme?
    let clientId: String
    let nonce: String
    let responseMode: ResponseMode?
    let state: String?

    public init(
      presentationDefinitionSource: PresentationDefinitionSource,
      clientMetaDataSource: ClientMetaDataSource?,
      clientIdScheme: ClientIdScheme?,
      clientId: String,
      nonce: String,
      responseMode: ResponseMode?,
      state: String?
    ) {
      self.presentationDefinitionSource = presentationDefinitionSource
      self.clientMetaDataSource = clientMetaDataSource
      self.clientIdScheme = clientIdScheme
      self.clientId = clientId
      self.nonce = nonce
      self.responseMode = responseMode
      self.state = state
    }
  }
}

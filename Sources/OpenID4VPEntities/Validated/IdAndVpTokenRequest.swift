import Foundation

extension ValidatedSiopOpenId4VPRequest {
  public struct IdAndVpTokenRequest {
    let idTokenType: [IdTokenType]
    let presentationDefinitionSource: PresentationDefinitionSource
    let clientMetaDataSource: ClientMetaDataSource?
    let clientIdScheme: ClientIdScheme?
    let clientId: String
    let nonce: String
    let scope: Scope?
    let responseMode: ResponseMode
    let state: String?
  }
}

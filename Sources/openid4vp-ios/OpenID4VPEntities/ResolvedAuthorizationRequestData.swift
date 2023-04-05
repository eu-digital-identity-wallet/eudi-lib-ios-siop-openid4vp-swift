import Foundation

public struct ResolvedAuthorizationRequestData {
  public let presentationDefinition: PresentationDefinition
  public let clientMetaData: ClientMetaData?
  public let nonce: Nonce
  public let responseMode: ResponseMode
}

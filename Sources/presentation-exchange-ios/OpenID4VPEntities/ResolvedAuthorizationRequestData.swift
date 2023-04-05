import Foundation

struct ResolvedAuthorizationRequestData {
  let presentationDefinition: PresentationDefinition
  let clientMetaData: ClientMetaData?
  let nonce: Nonce
  let responseMode: ResponseMode
}

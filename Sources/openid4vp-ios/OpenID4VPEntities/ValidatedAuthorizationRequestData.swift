import Foundation

public enum ResponseType: String, Codable {
  case vpToken = "vp_token"
  case IdToken = "id_token"
  case vpAndIdToken = "vp_token_id_token"
  case code = "code"
}

/*
 * https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-additional-verifier-metadat
 */
enum ClientIdScheme: String, Codable {
  case preRegistered = "pre-registered"
  case redirectUri = "redirect_uri"
  case entityId = "entity_id"
  case did = "did"
}

enum ClientMetaDataSource {
  case passByValue(metaData: ClientMetaData)
  case fetchByReference(url: URL)
}

public enum ResponseMode {
  case directPost(responseURI: URL)
  case none
}

struct ValidatedAuthorizationRequestData {
  let responseType: ResponseType
  let presentationDefinitionSource: PresentationDefinitionSource?
  let clientMetaDataSource: ClientMetaDataSource?
  let clientIdScheme: ClientIdScheme?
  let nonce: Nonce
  let scope: Scope?
  let responseMode: ResponseMode
}

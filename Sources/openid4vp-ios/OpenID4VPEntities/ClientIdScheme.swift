import Foundation

/*
 * https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-additional-verifier-metadat
 */
public enum ClientIdScheme: String, Codable {
  case preRegistered = "pre-registered"
  case redirectUri = "redirect_uri"
  case entityId = "entity_id"
  case did = "did"
}

extension ClientIdScheme {
  init(authorizationRequestData: AuthorizationRequestData) throws {
    guard
      authorizationRequestData.clientIdScheme == "pre-registered",
      let clientIdScheme = ClientIdScheme(rawValue: authorizationRequestData.clientIdScheme ?? "")
    else {
      throw ValidatedAuthorizationError.unsupportedClientIdScheme(authorizationRequestData.clientIdScheme)
    }
    
    self = clientIdScheme
  }
}

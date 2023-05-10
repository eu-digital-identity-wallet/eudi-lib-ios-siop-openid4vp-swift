import Foundation

/*
 * https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-additional-verifier-metadat
 */
public enum ClientIdScheme: String, Codable {
  case preRegistered = "pre-registered"
  case redirectUri = "redirect_uri"
  case entityId = "entity_id"
  case did = "did"
  case isox509 = "iso_x509"
}

extension ClientIdScheme {

  init(authorizationRequestObject: JSONObject) throws {
    let scheme = authorizationRequestObject["client_id_scheme"] as? String ?? "unknown"
    guard
      scheme == "pre-registered",
      let clientIdScheme = ClientIdScheme(rawValue: scheme)
    else {
      throw ValidatedAuthorizationError.unsupportedClientIdScheme(scheme)
    }

    self = clientIdScheme
  }

  init(authorizationRequestData: AuthorizationRequestUnprocessedData) throws {
    guard
      authorizationRequestData.clientIdScheme == "pre-registered",
      let clientIdScheme = ClientIdScheme(rawValue: authorizationRequestData.clientIdScheme ?? "")
    else {
      throw ValidatedAuthorizationError.unsupportedClientIdScheme(authorizationRequestData.clientIdScheme)
    }

    self = clientIdScheme
  }
}

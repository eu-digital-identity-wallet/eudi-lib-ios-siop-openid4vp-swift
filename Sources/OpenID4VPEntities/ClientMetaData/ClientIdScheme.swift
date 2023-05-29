import Foundation
import PresentationExchange

/*
 * https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-additional-verifier-metadat
 */

/// An enumeration representing different client ID schemes.
public enum ClientIdScheme: String, Codable {
  case preRegistered = "pre-registered"
  case redirectUri = "redirect_uri"
  case entityId = "entity_id"
  case did = "did"
  case isox509 = "iso_x509"
}

/// Extension providing additional functionality to the `ClientIdScheme` enumeration.
extension ClientIdScheme {

  /// Initializes a `ClientIdScheme` based on the authorization request object.
  /// - Parameter authorizationRequestObject: The authorization request object.
  /// - Throws: An error if the client ID scheme is unsupported.
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

  /// Initializes a `ClientIdScheme` based on the authorization request data.
  /// - Parameter authorizationRequestData: The authorization request data.
  /// - Throws: An error if the client ID scheme is unsupported.
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

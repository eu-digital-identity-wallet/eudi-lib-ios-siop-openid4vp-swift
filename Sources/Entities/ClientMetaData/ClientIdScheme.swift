/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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
  case x509SanDns = "x509_san_dns"
  case x509SanUri = "x509_san_uri"
}

/// Extension providing additional functionality to the `ClientIdScheme` enumeration.
extension ClientIdScheme {

  /// Initializes a `ClientIdScheme` based on the authorization request object.
  /// - Parameter authorizationRequestObject: The authorization request object.
  /// - Throws: An error if the client ID scheme is unsupported.
  init(authorizationRequestObject: JSONObject) throws {
    let scheme = authorizationRequestObject["client_id_scheme"] as? String ?? "unknown"
    guard scheme == "pre-registered" || scheme == "x509_san_dns" || scheme == "x509_san_uri",
      let clientIdScheme = ClientIdScheme(rawValue: scheme)
    else {
      throw ValidatedAuthorizationError.unsupportedClientIdScheme(scheme)
    }

    self = clientIdScheme
  }

  /// Initializes a `ClientIdScheme` based on the authorization request data.
  /// - Parameter authorizationRequestData: The authorization request data.
  /// - Throws: An error if the client ID scheme is unsupported.
  init(authorizationRequestData: AuthorisationRequestObject) throws {
    guard
      authorizationRequestData.clientIdScheme == "pre-registered",
      let clientIdScheme = ClientIdScheme(rawValue: authorizationRequestData.clientIdScheme ?? "")
    else {
      throw ValidatedAuthorizationError.unsupportedClientIdScheme(authorizationRequestData.clientIdScheme)
    }

    self = clientIdScheme
  }
}

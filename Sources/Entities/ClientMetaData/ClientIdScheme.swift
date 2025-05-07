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
import SwiftyJSON

/*
 * https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-additional-verifier-metadat
 */

/// An enumeration representing different client ID schemes.
public enum ClientIdScheme: String, Codable, Sendable {
  case preRegistered = "pre-registered"
  case redirectUri = "redirect_uri"
  case https = "https"
  case did = "did"
  case x509SanDns = "x509_san_dns"
  case x509SanUri = "x509_san_uri"
  case verifierAttestation = "verifier_attestation"
}

/// Extension providing additional functionality to the `ClientIdScheme` enumeration.
extension ClientIdScheme {
  
  /// Initializes a `ClientIdScheme` based on the authorization request object.
  /// - Parameter authorizationRequestObject: The authorization request object.
  /// - Throws: An error if the client ID scheme is unsupported.
  init(authorizationRequestObject: JSON) throws {
    let scheme = authorizationRequestObject["client_id_scheme"].string ?? "unknown"
    guard
      scheme == "redirect_uri" ||
      scheme == "pre-registered" ||
      scheme == "x509_san_dns" ||
      scheme == "x509_san_uri" ||
      scheme == "did" ||
      scheme == "https" ||
      scheme == "verifier_attestation",
      let clientIdScheme = ClientIdScheme(rawValue: scheme)
    else {
      throw ValidationError.unsupportedClientIdScheme(scheme)
    }
    
    self = clientIdScheme
  }
  
  /// Initializes a `ClientIdScheme` based on the authorization request data.
  /// - Parameter authorizationRequestData: The authorization request data.
  /// - Throws: An error if the client ID scheme is unsupported.
  init(authorizationRequestData: UnvalidatedRequestObject) throws {
    guard
      authorizationRequestData.clientIdScheme == "pre-registered",
      let clientIdScheme = ClientIdScheme(rawValue: authorizationRequestData.clientIdScheme ?? "")
    else {
      throw ValidationError.unsupportedClientIdScheme(authorizationRequestData.clientIdScheme)
    }
    
    self = clientIdScheme
  }
  
  /// Creates a new instance of `ClientIdScheme` from a raw value.
  ///
  /// - Parameter rawValue: The raw string value representing the client ID scheme.
  /// - Returns: An instance of `ClientIdScheme` if the raw value matches a valid scheme, or `nil` otherwise.
  public init?(rawValue: String) {
    switch rawValue {
    case "pre-registered":
      self = .preRegistered
    case "redirect_uri":
      self = .redirectUri
    case "https":
      self = .https
    case "did":
      self = .did
    case "x509_san_dns":
      self = .x509SanDns
    case "x509_san_uri":
      self = .x509SanUri
    case "verifier_attestation":
      self = .verifierAttestation
    default:
      return nil // Return nil if the raw value doesn't match any case
    }
  }
}

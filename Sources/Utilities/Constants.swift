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
import CryptoKit

public struct Constants {

  public static let WALLET_NONCE_FORM_PARAM = "wallet_nonce"
  public static let WALLET_METADATA_FORM_PARAM = "wallet_metadata"

  public static let CLIENT_ID = "client_id"
  public static let NONCE = "nonce"
  public static let SCOPE = "scope"
  public static let STATE = "state"
  public static let HTTPS = "https"
  public static let CLIENT_ID_SCHEME = "client_id_scheme"
  public static let PRESENTATION_DEFINITION = "presentation_definition"
  public static let DCQL_QUERY = "dcql_query"
  public static let VERIFIER_INFO = "verifier_info"
  public static let PRESENTATION_DEFINITION_URI = "presentation_definition_uri"
  public static let REQUEST_URI_METHOD = "request_url_method"
  public static let CLIENT_METADATA = "client_metadata"
  public static let TRANSACTION_DATA = "transaction_data"
  public static let RESPONSE_URI = "response_uri"

  public static let clientMetaDataJWKSString = """
  {
    "keys": [{
      "kty": "RSA",
      "e": "AQAB",
      "use": "sig",
      "kid": "a4e1bbe6-26e8-480b-a364-f43497894453",
      "iat": 1683559586,
    "n": "xHI9zoXS-fOAFXDhDmPMmT_UrU1MPimy0xfP-sL0Iu4CQJmGkALiCNzJh9v343fqFT2hfrbigMnafB2wtcXZeEDy6Mwu9QcJh1qLnklW5OOdYsLJLTyiNwMbLQXdVxXiGby66wbzpUymrQmT1v80ywuYd8Y0IQVyteR2jvRDNxy88bd2eosfkUdQhNKUsUmpODSxrEU2SJCClO4467fVdPng7lyzF2duStFeA2vUkZubor3EcrJ72JbZVI51YDAqHQyqKZIDGddOOvyGUTyHz9749bsoesqXHOugVXhc2elKvegwBik3eOLgfYKJwisFcrBl62k90RaMZpXCxNO4Ew"
    }]
  }
  """

  public static func testClientMetaData() -> ClientMetaData {
    .init(
      jwks: Constants.clientMetaDataJWKSString,
      vpFormatsSupported: nil
    )
  }

  public static let testClientId = "https%3A%2F%2Fclient.example.org%2Fcb"
  public static let testClient: Client = .preRegistered(
    clientId: "https%3A%2F%2Fclient.example.org%2Fcb",
    legalName: "Verifier"
  )
  public static let testNonce = "0S6_WzA2Mj"
  public static let testScope = "one two three"

  public static let testResponseMode: ResponseMode = .directPost(responseURI: URL(string: "https://respond.here")!)

  public static let testDirectPostJwtResponseMode: ResponseMode = .directPostJWT(
    responseURI: URL(string: "https://respond.here")!
  )

  static func generateRandomJWT() -> String {
    // Define the header
    let header = #"{"alg":"HS256","typ":"JWT"}"#

    // Define the claims
    let claims = #"{"iss":"issuer","sub":"subject","aud":["audience"],"exp":1679911600,"iat":1657753200}"#

    // Create the base64url-encoded segments
    let encodedHeader = header.base64urlEncode
    let encodedClaims = claims.base64urlEncode

    // Concatenate the header and claims segments with a dot separator
    let encodedToken = "\(encodedHeader).\(encodedClaims)"

    // Define the secret key for signing
    let secretKey = "your_secret_key".data(using: .utf8)!

    // Sign the token with HMAC-SHA256
    let signature = HMAC<SHA256>.authenticationCode(for: Data(encodedToken.utf8), using: SymmetricKey(data: secretKey))

    // Base64url-encode the signature
    let encodedSignature = Data(signature).base64EncodedString()

    // Concatenate the encoded token and signature with a dot separator
    let jwt = "\(encodedToken).\(encodedSignature)"

    return jwt
  }

  static func generateRandomBase64String() -> String? {
    let randomData = Data.randomData(length: 32)
    let base64URL = randomData.base64URLEncodedString()
    return base64URL
  }

  static let presentationSubmissionKey = "presentation_submission"
}

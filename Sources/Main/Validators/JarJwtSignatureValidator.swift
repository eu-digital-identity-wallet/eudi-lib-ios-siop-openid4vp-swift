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

public class JarJwtSignatureValidator {

  public let walletOpenId4VPConfig: WalletOpenId4VPConfiguration

  public init(walletOpenId4VPConfig: WalletOpenId4VPConfiguration) {
    self.walletOpenId4VPConfig = walletOpenId4VPConfig
  }

  public func validate(clientId: String, jwt: JWTString) async throws -> AuthorisationRequestObject? {
    guard let jwt = JSONWebToken(jsonWebToken: jwt) else {
      throw ValidatedAuthorizationError.invalidJwtPayload
    }

    try await doValidate(clientId: clientId, jwt: jwt)

    return requestObject(claimsSet: try JWTClaimsSet.parse(jwt.payload))
  }

  private func doValidate(clientId: String, jwt: JSONWebToken) async throws {
    let claimSet = jwt.payload

    guard let jwtClientId = claimSet["client_id"] as? String else {
      throw ValidatedAuthorizationError.invalidClientId
    }

    guard clientId == jwtClientId else {
      throw ValidatedAuthorizationError.clientIdMismatch(clientId, jwtClientId)
    }

    guard let clientIdScheme = claimSet["client_id_scheme"] as? String else {
      throw ValidatedAuthorizationError.unsupportedClientIdScheme(nil)
    }

    guard let supportedClientIdScheme = walletOpenId4VPConfig.supportedClientIdSchemes.first(where: {
      $0.scheme == ClientIdScheme(rawValue: clientIdScheme)
    }) else {
      throw ValidatedAuthorizationError.unsupportedClientIdScheme(nil)
    }

    switch supportedClientIdScheme.scheme {
    case .preRegistered:
      try validatePreregistered(
        supportedClientIdScheme: supportedClientIdScheme,
        clientId: clientId,
        jwt: jwt
      )
    default: throw ValidatedAuthorizationError.unsupportedClientIdScheme(
        supportedClientIdScheme.scheme.rawValue
      )
    }
  }

  private func validatePreregistered(
    supportedClientIdScheme: SupportedClientIdScheme,
    clientId: String,
    jwt: JSONWebToken
  ) throws {

    guard supportedClientIdScheme.scheme == .preRegistered else {
      throw ValidatedAuthorizationError.unsupportedClientIdScheme(
          supportedClientIdScheme.scheme.rawValue
        )
    }

    switch supportedClientIdScheme {
    case .preregistered: return
    default: throw ValidatedAuthorizationError.unsupportedClientIdScheme(
        supportedClientIdScheme.scheme.rawValue
      )
    }
  }

  private func verifySignature(jwt: JSONWebToken) {
  }

  private func requestObject(claimsSet: JWTClaimsSet) -> AuthorisationRequestObject {
    let claims = claimsSet.claims
    return AuthorisationRequestObject(
      responseType: claims["response_type"] as? String,
      responseUri: claims["response_uri"] as? String,
      redirectUri: claims["redirect_uri"] as? String,
      presentationDefinition: claims["presentation_definition"] as? String,
      presentationDefinitionUri: claims["presentation_definition_uri"] as? String,
      request: claims["request"] as? String,
      requestUri: claims["requestUri"] as? String,
      clientMetaData: claims["client_metadata"] as? String,
      clientId: claims["client_id"] as? String,
      clientMetadataUri: claims["client_metadata_uri"] as? String,
      clientIdScheme: claims["client_id_scheme"] as? String,
      nonce: claims["nonce"] as? String,
      scope: claims["scope"] as? String,
      responseMode: claims["response_Mmode"] as? String,
      state: claims["state"] as? String,
      idTokenType: claims["id_token_type"] as? String,
      supportedAlgorithm: claims["supported_algorithm"] as? String
    )
  }
}

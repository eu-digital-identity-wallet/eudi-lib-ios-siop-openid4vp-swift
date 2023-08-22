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

public actor JarJwtSignatureValidator {
  
  public let walletOpenId4VPConfig: WalletOpenId4VPConfiguration?
  private let resolver = WebKeyResolver()
  
  public init(walletOpenId4VPConfig: WalletOpenId4VPConfiguration?) {
    self.walletOpenId4VPConfig = walletOpenId4VPConfig
  }
  
  public func validate(clientId: String?, jwt: JWTString) async throws {
    guard let jwt = JSONWebToken(jsonWebToken: jwt) else {
      throw ValidatedAuthorizationError.invalidJwtPayload
    }
    
    try await doValidate(clientId: clientId, jwt: jwt)
  }
  
  private func doValidate(clientId: String?, jwt: JSONWebToken) async throws {
    let claimSet = jwt.payload
    
    guard let clientId = clientId else {
      throw ValidatedAuthorizationError.missingRequiredField("client_id")
    }
    
    guard let jwtClientId = claimSet["client_id"] as? String else {
      throw ValidatedAuthorizationError.invalidClientId
    }
    
    guard clientId == jwtClientId else {
      throw ValidatedAuthorizationError.clientIdMismatch(clientId, jwtClientId)
    }
    
    guard let scheme = claimSet["client_id_scheme"] as? String else {
      throw ValidatedAuthorizationError.unsupportedClientIdScheme(nil)
    }
    
    guard let clientIdScheme = ClientIdScheme(rawValue: scheme) else {
      throw ValidatedAuthorizationError.unsupportedClientIdScheme(nil)
    }
    
    switch clientIdScheme {
    case .preRegistered:
      let supported: SupportedClientIdScheme? = walletOpenId4VPConfig?.supportedClientIdSchemes.first(where: { $0.scheme == clientIdScheme })
      try await validatePreregistered(
        supportedClientIdScheme: supported,
        clientId: clientId,
        jwt: jwt
      )
    case .isox509: break
    default: break
    }
  }
  
  private func validatePreregistered(
    supportedClientIdScheme: SupportedClientIdScheme?,
    clientId: String,
    jwt: JSONWebToken
  ) async throws {
    
    guard let supportedClientIdScheme = supportedClientIdScheme,
          supportedClientIdScheme.scheme == .preRegistered else {
      throw ValidatedAuthorizationError.unsupportedClientIdScheme(
        supportedClientIdScheme?.scheme.rawValue
      )
    }
    
    switch supportedClientIdScheme {
    case .preregistered(let clients):
      guard let client = clients[clientId] else {
        throw ValidatedAuthorizationError.validationError("Client with client_id \(clientId) is not pre-registered")
      }
      await verifySignature(
        jwt: jwt,
        client: client
      )
    default: throw ValidatedAuthorizationError.unsupportedClientIdScheme(
      supportedClientIdScheme.scheme.rawValue
    )
    }
  }
  
  private func verifySignature(
    jwt: JSONWebToken,
    client: PreregisteredClient
  ) async {
    let jwk = await resolver.resolve(source: client.jwkSetSource)
    print(jwk)
  }
}

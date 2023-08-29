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
import JOSESwift

public actor JarJwtSignatureValidator {
  
  public let walletOpenId4VPConfig: WalletOpenId4VPConfiguration?
  private let resolver = WebKeyResolver()
  private let objectType: JOSEObjectType
  
  public init(
    walletOpenId4VPConfig: WalletOpenId4VPConfiguration?,
    objectType: JOSEObjectType = .REQ_JWT
  ) {
    self.walletOpenId4VPConfig = walletOpenId4VPConfig
    self.objectType = objectType
  }
  
  public func validate(clientId: String?, jwt: JWTString) async throws {
    let jwt = try JWS(compactSerialization: jwt)
    try await doValidate(clientId: clientId, jws: jwt)
  }
  
  private func doValidate(clientId: String?, jws: JWS) async throws {
    guard let dictionary = try JSONSerialization.jsonObject(with: jws.payload.data()) as? [String: Any] else {
      throw ValidatedAuthorizationError.validationError("Invalid JWS payload")
    }
    let claimSet = dictionary
    
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
        jws: jws
      )
    case .isox509: break
    default: break
    }
  }
  
  private func validatePreregistered(
    supportedClientIdScheme: SupportedClientIdScheme?,
    clientId: String,
    jws: JWS
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
      try await verifySignature(
        jws: jws,
        client: client
      )
    default: throw ValidatedAuthorizationError.unsupportedClientIdScheme(
      supportedClientIdScheme.scheme.rawValue
    )
    }
  }
  
  private func verifySignature(
    jws: JWS,
    client: PreregisteredClient
  ) async throws {
    
    if jws.header.typ != objectType.rawValue {
      throw ValidatedAuthorizationError.validationError("Header object type mismatch")
    }
    
    let jwk = await resolver.resolve(source: client.jwkSetSource)
    switch jwk {
    case .success(let set):
      guard let key = set?.keys.first(where: { $0.alg == jws.header.algorithm?.rawValue }),
            let alg = key.alg,
            let algorithm = SignatureAlgorithm(rawValue: alg)
      else {
        throw ValidatedAuthorizationError.validationError("Could not resolve key from JWK source")
      }
      
      let publicKey = try RSAPublicKey(data: key.toDictionary().toThrowingJSONData())
      let secKey = try publicKey.converted(to: SecKey.self)
      if let verifier = Verifier(verifyingAlgorithm: algorithm, key: secKey) {
        _ = try jws.validate(using: verifier)
      } else {
        throw ValidatedAuthorizationError.validationError("Unable to verify signature")
      }

    case .failure:
      throw ValidatedAuthorizationError.validationError("Could not resolve key from JWK source")
    }
  }
}

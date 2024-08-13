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

actor VerifierAttestationIssuer {

  static let ID = "Attestation Issuer"
  
  let attestationDuration: TimeInterval = 100.0
  
  lazy var algAndKey: (algorithm: SignatureAlgorithm, key: SecKey) = {
    let privateKey = try? KeyController.generateECDHPrivateKey()
    return (.ES256, privateKey!)
  }()
  
  lazy var verifier: Verifier? = {
    
    let publicKey: SecKey = try! KeyController.generateECDHPublicKey(from: self.algAndKey.key)
    let verifier: Verifier? = .init(
      verifyingAlgorithm: .ES256,
      key: publicKey
    )
    return verifier
  }()
  
  init() {
  }
  
  func attestation(
    clock: TimeInterval,
    clientId: String,
    redirectUris: [URL]? = nil,
    responseUris: [URL]? = nil
  ) throws -> JWS {
    guard let publicKey: SecKey = try? KeyController.generateECDHPublicKey(
      from: self.algAndKey.key
    ) else {
      throw ValidatedAuthorizationError.validationError("Unable to get private key")
    }
    
    let ecPublicJwk = try ECPublicKey(
      publicKey: publicKey,
      additionalParameters: [
        "use": "enc",
        "kid": UUID().uuidString,
        "alg": "ECDH-ES"
      ]
    )
    
    let now = Date().timeIntervalSince1970
    let payload = [
      "iss": Self.ID,
      "sub": clientId,
      "iat": now,
      "exp": now + attestationDuration,
      "cnf": [
        "jwk": try ecPublicJwk.toDictionary()
      ],
      "redirect_uris": [],
      "response_uris": []
    ] as [String : Any]
    
    return try JWS(
      header: .init(
        parameters: [
          "typ": "verifier-attestation+jwt",
          "alg": "ES256"
        ]
      ),
      payload: Payload(
        payload.toThrowingJSONData()
      ),
      signer: .init(
        signingAlgorithm: algAndKey.algorithm,
        key: algAndKey.key
      )!
    )
  }
}

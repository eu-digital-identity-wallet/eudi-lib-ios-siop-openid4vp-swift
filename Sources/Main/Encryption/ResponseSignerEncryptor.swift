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

let globalKeyManagementAlgorith: String = "RSA-OAEP-256"

internal actor ResponseSignerEncryptor {

  let rsaFamily: [JWEAlgorithm] = ["RSA1_5", "RSA_OAEP", "RSA_OAEP_256", "RSA_OAEP_384", "RSA_OAEP_512"]
  let ecFamily: [JWEAlgorithm] = ["ECDH_ES", "ECDH_ES_A128KW", "ECDH_ES_A192KW", "ECDH_ES_A256KW"]

  func signEncryptResponse(
    spec: JarmSpec,
    data: AuthorizationResponsePayload
  ) throws -> String {
    switch spec {
    case .resolution(
      holderId: let holderId,
      jarmOption: let jarmOption
    ):
      switch jarmOption {
      case .signedResponse(
        responseSigningAlg: let responseSigningAlg,
        signingKeySet: let signingKeySet,
        signingKey: let signingKey
      ):
        return try sign(
          holderId: holderId,
          responseSigningAlg: responseSigningAlg,
          signingKeySet: signingKeySet,
          signingKey: signingKey,
          data: data
        ).compactSerializedString

      case .encryptedResponse(
        responseSigningAlg: let responseSigningAlg,
        responseEncryptionEnc: let responseEncryptionEnc,
        signingKeySet: let signingKeySet,
        signingKey: let signingKey
      ):
        return try encrypt(
          holderId: holderId,
          responseSigningAlg: responseSigningAlg,
          responseEncryptionEnc: responseEncryptionEnc,
          signingKeySet: signingKeySet,
          data: data
        ).compactSerializedString

      case .signedAndEncryptedResponse(
        signed: let signed,
        encrypted: let encrypted
      ):
        return try signAndEncrypt(
          holderId: holderId,
          signed: signed,
          encrypted: encrypted,
          data: data
        ).compactSerializedString
      }
    }
  }
}

private extension ResponseSignerEncryptor {

  func sign(
    holderId: String,
    option: JarmOption,
    data: AuthorizationResponsePayload
  ) throws -> JWS {
    switch option {
    case .signedResponse(
      responseSigningAlg: let responseSigningAlg,
      signingKeySet: let signingKeySet,
      signingKey: let signingKey
    ):
      return try sign(
        holderId: holderId,
        responseSigningAlg: responseSigningAlg,
        signingKeySet: signingKeySet,
        signingKey: signingKey,
        data: data
      )
    default: throw ValidatedAuthorizationError.invalidJarmOption
    }
  }

  func sign(
    holderId: String,
    responseSigningAlg: JWSAlgorithm,
    signingKeySet: WebKeySet,
    signingKey: SecKey,
    data: AuthorizationResponsePayload
  ) throws -> JWS {
    guard let signatureAlgorithm = SignatureAlgorithm(rawValue: responseSigningAlg) else {
      throw ValidatedAuthorizationError.unsupportedAlgorithm(responseSigningAlg)
    }

    let keyAndSigner = try self.keyAndSigner(
      jwsAlgorithm: signatureAlgorithm,
      keySet: signingKeySet,
      signingKey: signingKey
    )

    return try JWS(
      header: JWSHeader(parameters: [
        "alg": signatureAlgorithm.rawValue,
        "kid": keyAndSigner.key.kid
      ]),
      payload: Payload(data
        .toDictionary()
        .merging([
          JWTClaimNames.issuer: holderId,
          JWTClaimNames.issuedAt: Int(Date().timeIntervalSince1970.rounded())
        ], uniquingKeysWith: { _, new in
          new
        })
        .toThrowingJSONData()
      ),
      signer: keyAndSigner.signer
    )
  }

  func encrypt(
    holderId: String,
    responseSigningAlg: JWEAlgorithm,
    responseEncryptionEnc: EncryptionMethod,
    signingKeySet: WebKeySet,
    data: AuthorizationResponsePayload
  ) throws -> JWE {

    let keyAndEncryptor = try keyAndEncryptor(
      jweAlgorithm: responseSigningAlg,
      keySet: signingKeySet
    )

    let header = try JWEHeader(parameters: [
      "alg": globalKeyManagementAlgorith,
      "enc": responseEncryptionEnc.rawValue,
      "kid": keyAndEncryptor.key.kid
    ])

    let jwe = try JWE(
      header: header,
      payload: Payload(data
        .toDictionary()
        .merging([
          JWTClaimNames.issuer: holderId,
          JWTClaimNames.issuedAt: Int(Date().timeIntervalSince1970.rounded())
        ], uniquingKeysWith: { _, new in
          new
        })
        .toThrowingJSONData()
      ),
      encrypter: keyAndEncryptor.encrypter
    )
    
    return jwe
  }

  func signAndEncrypt(
    holderId: String,
    signed: JarmOption,
    encrypted: JarmOption,
    data: AuthorizationResponsePayload
  ) throws -> JWE {
    let signedJwt = try sign(holderId: holderId, option: signed, data: data)
    switch encrypted {
    case .encryptedResponse(
      responseSigningAlg: let responseSigningAlg,
      responseEncryptionEnc: let responseEncryptionEnc,
      signingKeySet: let signingKeySet,
      signingKey: let signingKey
    ):
      let keyAndEncryptor = try keyAndEncryptor(
        jweAlgorithm: responseEncryptionEnc.rawValue,
        keySet: signingKeySet
      )

      let header = try JWEHeader(parameters: [
        "alg": globalKeyManagementAlgorith,
        "enc": responseEncryptionEnc.rawValue
      ])

      return try JWE(
        header: header,
        payload: Payload(signedJwt.compactSerializedData),
        encrypter: keyAndEncryptor.encrypter
      )
    default: throw ValidatedAuthorizationError.validationError("Unable to retrieve encrypted from  JarmOption")
    }
  }

  func keyAndSigner(
    jwsAlgorithm: SignatureAlgorithm,
    keySet: WebKeySet,
    signingKey: SecKey
  ) throws -> (key: WebKeySet.Key, signer: Signer<SecKey>) {
    let key = try keySet.keys.first { key in
      key.alg == jwsAlgorithm.rawValue
    } ?? { throw ValidatedAuthorizationError.invalidJWTWebKeySet }()

    guard let alg = key.alg, let signatureAlgorithm = SignatureAlgorithm(rawValue: alg) else {
      throw ValidatedAuthorizationError.unsupportedAlgorithm(key.alg ?? "")
    }

    guard let signer = Signer(
      signingAlgorithm: signatureAlgorithm,
      key: signingKey
    ) else {
      throw ValidatedAuthorizationError.invalidSigningKey
    }
    return (key, signer)
  }

  func keyAndEncryptor(
    jweAlgorithm: JWEAlgorithm,
    keySet: WebKeySet
  ) throws -> (key: WebKeySet.Key, encrypter: Encrypter<SecKey>) {

    let encrypters = try findEncrypters(algorithm: jweAlgorithm, keySet: keySet)
    if let firstKey = encrypters.keys.first, let firstValue = encrypters[firstKey] {
      return (key: firstKey, encrypter: firstValue)
    }
    throw ValidatedAuthorizationError.validationError("Unable to create key/encryptor pair")
  }

  // swiftlint:disable line_length
  func createEncrypter(
    jweAlgorithm: JWEAlgorithm,
    key: WebKeySet.Key
  ) throws -> Encrypter<SecKey>? {

    let data = try key.toDictionary().toThrowingJSONData()
    let publicKey = try RSAPublicKey(data: data)
    let secKey: SecKey = try publicKey.converted(to: SecKey.self)

    guard let keyAlgorithm: KeyManagementAlgorithm = .init(rawValue: globalKeyManagementAlgorith) else {
      throw ValidatedAuthorizationError.validationError("Unknown key management algorithm \(jweAlgorithm)")
    }

//    guard let contentEncryptionAlgorithm: ContentEncryptionAlgorithm = .init(rawValue: jweAlgorithm) else {
//      throw ValidatedAuthorizationError.validationError("Unknown content encryption algorith \(jweAlgorithm)")
//    }

    // TODO: proper family checking
    if true { // rsaFamily.contains(jweAlgorithm) {
      return Encrypter(
        keyManagementAlgorithm: keyAlgorithm,
        contentEncryptionAlgorithm: .A128CBCHS256,
        encryptionKey: secKey
      )
    }
    throw ValidatedAuthorizationError.validationError("JWE Algorithm should be of the RSA family")
  }
  // swiftlint:enable line_length

  func findEncrypters(
    algorithm: JWEAlgorithm,
    keySet: WebKeySet
  ) throws -> [WebKeySet.Key: Encrypter<SecKey>] {
    func encrypter(for key: WebKeySet.Key) throws -> Encrypter<SecKey>? {
      return try createEncrypter(jweAlgorithm: algorithm, key: key)
    }

    return Dictionary(uniqueKeysWithValues: keySet.keys.compactMap { key in
      try? encrypter(for: key).map { (key, $0) }
  })
  }
}

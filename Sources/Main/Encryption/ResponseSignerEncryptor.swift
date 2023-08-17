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

internal actor ResponseSignerEncryptor {

  let rsaFamily: [JWEAlgorithm] = ["RSA-OAEP-256"]
  let ecFamily: [JWEAlgorithm] = ["ECDH-ES"]

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
        signingKeySet: let signingKeySet
      ):
        return try sign(
          holderId: holderId,
          responseSigningAlg: responseSigningAlg,
          signingKeySet: signingKeySet,
          data: data
        ).compactSerializedString

      case .encryptedResponse(
        responseSigningAlg: let responseSigningAlg,
        responseEncryptionEnc: let responseEncryptionEnc,
        signingKeySet: let signingKeySet
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
      signingKeySet: let signingKeySet
    ):
      return try sign(
        holderId: holderId,
        responseSigningAlg: responseSigningAlg,
        signingKeySet: signingKeySet,
        data: data
      )
    default: throw ValidatedAuthorizationError.invalidJarmOption
    }
  }

  func sign(
    holderId: String,
    responseSigningAlg: JWSAlgorithm,
    signingKeySet: WebKeySet,
    data: AuthorizationResponsePayload
  ) throws -> JWS {
    guard let signatureAlgorithm = SignatureAlgorithm(rawValue: responseSigningAlg) else {
      throw ValidatedAuthorizationError.unsupportedAlgorithm(responseSigningAlg)
    }

    let keyAndSigner = try self.keyAndSigner(
      jwsAlgorithm: signatureAlgorithm,
      keySet: signingKeySet
    )

    return try JWS(
      header: JWSHeader(parameters: [
        "alg": signatureAlgorithm,
        "kid": keyAndSigner.key.kid
      ]),
      payload: Payload(data
        .toDictionary()
        .merging([:], uniquingKeysWith: { _, new in
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
      jwsAlgorithm: responseSigningAlg,
      keySet: signingKeySet
    )

    let header = try JWEHeader(parameters: [
      "alg": responseSigningAlg,
      "enc": responseEncryptionEnc,
      "kid": keyAndEncryptor.key.kid
    ])

    return try JWE(
      header: header,
      payload: Payload(data
        .toDictionary()
        .merging([:], uniquingKeysWith: { _, new in
          new
        })
        .toThrowingJSONData()
      ),
      encrypter: keyAndEncryptor.encrypter
    )
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
      signingKeySet: let signingKeySet
    ):
      let keyAndEncryptor = try keyAndEncryptor(
        jwsAlgorithm: responseSigningAlg,
        keySet: signingKeySet
      )

      let header = try JWEHeader(parameters: [
        "alg": responseSigningAlg,
        "enc": responseEncryptionEnc
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
    keySet: WebKeySet
  ) throws -> (key: WebKeySet.Key, signer: Signer<RSAPrivateKey>) {
    let key = try keySet.keys.first { key in
      key.alg == jwsAlgorithm.rawValue
    } ?? { throw ValidatedAuthorizationError.invalidJWTWebKeySet }()

    let data = try key.toDictionary().toThrowingJSONData()
    guard let alg = key.alg, let signatureAlgorithm = SignatureAlgorithm(rawValue: alg) else {
      throw ValidatedAuthorizationError.unsupportedAlgorithm(key.alg ?? "")
    }

    guard let signer = Signer(
      signingAlgorithm: signatureAlgorithm,
      key: try RSAPrivateKey(data: data)
    ) else {
      throw ValidatedAuthorizationError.invalidSigningKey
    }
    return (key, signer)
  }

  func keyAndEncryptor(
    jwsAlgorithm: JWEAlgorithm,
    keySet: WebKeySet
  ) throws -> (key: WebKeySet.Key, encrypter: Encrypter<RSAPublicKey>) {

    let encrypters = try findEncrypters(algorithm: jwsAlgorithm, keySet: keySet)
    if let firstKey = encrypters.keys.first, let firstValue = encrypters[firstKey] {
      return (key: firstKey, encrypter: firstValue)
    }
    throw ValidatedAuthorizationError.validationError("Unable to create key/encryptor pair")
  }

  func createEncrypter(
    jweAlgorithm: JWEAlgorithm,
    key: WebKeySet.Key
  ) throws -> Encrypter<RSAPublicKey>? {

    let data = try key.toDictionary().toThrowingJSONData()
    let publicKey = try RSAPublicKey(data: data)

    guard let keyAlgorithm: KeyManagementAlgorithm = .init(rawValue: jweAlgorithm) else {
      throw ValidatedAuthorizationError.validationError("Unknown key management algorithm \(jweAlgorithm)")
    }

    guard let contentEncryptionAlgorithm: ContentEncryptionAlgorithm = .init(rawValue: jweAlgorithm) else {
      throw ValidatedAuthorizationError.validationError("Unknown content encryption algorith \(jweAlgorithm)")
    }

    if rsaFamily.contains(jweAlgorithm) {
      return Encrypter(
        keyManagementAlgorithm: keyAlgorithm,
        contentEncryptionAlgorithm: contentEncryptionAlgorithm,
        encryptionKey: publicKey
      )
    }
    throw ValidatedAuthorizationError.validationError("JWE Algorithm should be of the RSA family")
  }

  func findEncrypters(
    algorithm: JWEAlgorithm,
    keySet: WebKeySet
  ) throws -> [WebKeySet.Key: Encrypter<RSAPublicKey>] {
    func encrypter(for key: WebKeySet.Key) throws -> Encrypter<RSAPublicKey>? {
      return try createEncrypter(jweAlgorithm: algorithm, key: key)
    }

    return Dictionary(uniqueKeysWithValues: keySet.keys.compactMap { key in
      try? encrypter(for: key).map { (key, $0) }
  })
  }
}

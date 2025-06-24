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

  func signEncryptResponse(
    requirement: JARMRequirement,
    data: AuthorizationResponsePayload
  ) throws -> String {
    switch requirement {
    case .signed(
      let responseSigningAlg,
      let privateKey,
      let webKeySet
    ): return try sign(
      responseSigningAlg: responseSigningAlg,
      signingKeySet: webKeySet,
      signingKey: privateKey,
      data: data
    ).compactSerializedString
      
    case .encrypted(
      let responseEncryptionAlg,
      let responseEncryptionEnc,
      let clientKey
    ): return try encrypt(
      responseEncryptionAlg: responseEncryptionAlg,
      responseEncryptionEnc: responseEncryptionEnc,
      signingKeySet: clientKey,
      data: data
    ).compactSerializedString
      
    case .signedAndEncrypted(
      let signed,
      let encrypted
    ): return try signAndEncrypt(
      signed: signed,
      encrypted: encrypted,
      data: data
    ).compactSerializedString
      
    case .noRequirement:
      throw ValidationError.invalidJarmRequirement
    }
  }
}

private extension ResponseSignerEncryptor {

  func sign(
    requirement: JARMRequirement,
    data: AuthorizationResponsePayload
  ) throws -> JWS {
    switch requirement {
    case .signed(
      let responseSigningAlg,
      let signingKey,
      let signingKeySet
    ): return try sign(
      responseSigningAlg: responseSigningAlg,
      signingKeySet: signingKeySet,
      signingKey: signingKey,
      data: data
    )
    default: throw ValidationError.invalidJarmRequirement
    }
  }

  func sign(
    responseSigningAlg: JWSAlgorithm,
    signingKeySet: WebKeySet,
    signingKey: SecKey,
    data: AuthorizationResponsePayload
  ) throws -> JWS {
    guard let signatureAlgorithm = SignatureAlgorithm(rawValue: responseSigningAlg.name) else {
      throw ValidationError.unsupportedAlgorithm(responseSigningAlg.name)
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
    responseEncryptionAlg: JWEAlgorithm,
    responseEncryptionEnc: JOSEEncryptionMethod,
    signingKeySet: WebKeySet,
    data: AuthorizationResponsePayload
  ) throws -> JWE {

    let keyAndEncryptor = try keyAndEncryptor(
      jweAlgorithm: responseEncryptionAlg,
      encryptionMethod: responseEncryptionEnc,
      keySet: signingKeySet
    )

    let parameters: [String: Any?] = [
      "alg": responseEncryptionAlg.name,
      "enc": responseEncryptionEnc.name,
      "kid": keyAndEncryptor.key.kid,
      "apv": data.nonce.base64urlEncode,
      "apu": data.apu
    ].filter { $0.value != nil }

    let header = try JWEHeader(parameters: parameters as [String: Any])

    let jwe = try JWE(
      header: header,
      payload: Payload(
        data.toDictionary().toThrowingJSONData()
      ),
      encrypter: keyAndEncryptor.encrypter
    )
    return jwe
  }

  func signAndEncrypt(
    signed: JARMRequirement,
    encrypted: JARMRequirement,
    data: AuthorizationResponsePayload
  ) throws -> JWE {
    let signedJwt = try sign(requirement: signed, data: data)
    switch encrypted {
    case .encrypted(
      let responseSigningAlg,
      let responseEncryptionEnc,
      let signingKeySet
    ):
      let keyAndEncryptor = try keyAndEncryptor(
        jweAlgorithm: responseSigningAlg,
        encryptionMethod: responseEncryptionEnc,
        keySet: signingKeySet
      )

      let parameters: [String: Any?] = [
        "alg": responseSigningAlg.name,
        "enc": responseEncryptionEnc.name,
        "kid": keyAndEncryptor.key.kid,
        "apv": data.nonce.base64urlEncode,
        "apu": data.apu
      ].filter { $0.value != nil }
      let header = try JWEHeader(parameters: parameters as [String: Any])

      return try JWE(
        header: header,
        payload: Payload(signedJwt.compactSerializedData),
        encrypter: keyAndEncryptor.encrypter
      )
    default:
      throw ValidationError.validationError(
        "Unable to retrieve encrypted from  JARMRequirement"
      )
    }
  }

  func keyAndSigner(
    jwsAlgorithm: SignatureAlgorithm,
    keySet: WebKeySet,
    signingKey: SecKey
  ) throws -> (key: WebKeySet.Key, signer: Signer) {
    let key = try keySet.keys.first { key in
      key.alg == jwsAlgorithm.rawValue
    } ?? { throw ValidationError.invalidJWTWebKeySet }()

    guard let alg = key.alg, let signatureAlgorithm = SignatureAlgorithm(rawValue: alg) else {
      throw ValidationError.unsupportedAlgorithm(key.alg ?? "")
    }

    guard let signer = Signer(
      signatureAlgorithm: signatureAlgorithm,
      key: signingKey
    ) else {
      throw ValidationError.invalidSigningKey
    }
    return (key, signer)
  }

  func keyAndEncryptor(
    jweAlgorithm: JWEAlgorithm,
    encryptionMethod: JOSEEncryptionMethod,
    keySet: WebKeySet
  ) throws -> (key: WebKeySet.Key, encrypter: Encrypter) {

    let encrypters = try findEncrypters(
      jweAlgorithm: jweAlgorithm,
      encryptionMethod: encryptionMethod,
      keySet: keySet
    )
    if let firstKey = encrypters.keys.first, let firstValue = encrypters[firstKey] {
      return (key: firstKey, encrypter: firstValue)
    }
    throw ValidationError.validationError("Unable to create key/encryptor pair")
  }

  // swiftlint:disable line_length
  func createEncrypter(
    jweAlgorithm: JWEAlgorithm,
    encryptionMethod: JOSEEncryptionMethod,
    key: WebKeySet.Key
  ) throws -> Encrypter? {

    let data = try key.toDictionary().toThrowingJSONData()

    guard let keyAlgorithm: KeyManagementAlgorithm = .init(rawValue: jweAlgorithm.name) else {
      throw ValidationError.validationError("Create encrypter - Unknown key management algorithm")
    }

    guard let contentEncryptionAlgorithm: ContentEncryptionAlgorithm = .init(rawValue: encryptionMethod.name) else {
      throw ValidationError.validationError("Create encrypter - Unknown content encryption algorithm")
    }

    if JWEAlgorithm.Family.parse(.RSA).contains(jweAlgorithm) {
      let publicKey = try RSAPublicKey(data: data)
      let secKey: SecKey = try publicKey.converted(to: SecKey.self)
      return Encrypter(
        keyManagementAlgorithm: keyAlgorithm,
        contentEncryptionAlgorithm: contentEncryptionAlgorithm,
        encryptionKey: secKey
      )
    } else if JWEAlgorithm.Family.parse(.ECDH_ES).contains(jweAlgorithm) {
      let publicKey = try ECPublicKey(data: data)
      return Encrypter(
        keyManagementAlgorithm: keyAlgorithm,
        contentEncryptionAlgorithm: contentEncryptionAlgorithm,
        encryptionKey: publicKey
      )
    } else {
      throw ValidationError.validationError("JWE Algorithm should be of the RSA or ECDH family")
    }
  }

  func findEncrypters(
    jweAlgorithm: JWEAlgorithm,
    encryptionMethod: JOSEEncryptionMethod,
    keySet: WebKeySet
  ) throws -> [WebKeySet.Key: Encrypter] {
    func encrypter(for key: WebKeySet.Key) throws -> Encrypter? {
      return try createEncrypter(
        jweAlgorithm: jweAlgorithm,
        encryptionMethod: encryptionMethod, key: key
      )
    }

    return Dictionary(uniqueKeysWithValues: keySet.keys.compactMap { key in
      try? encrypter(for: key).map { (key, $0) }
    })
  }
}

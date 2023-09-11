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
    guard let signatureAlgorithm = SignatureAlgorithm(rawValue: responseSigningAlg.name) else {
      throw ValidatedAuthorizationError.unsupportedAlgorithm(responseSigningAlg.name)
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
    responseEncryptionEnc: JOSEEncryptionMethod,
    signingKeySet: WebKeySet,
    data: AuthorizationResponsePayload
  ) throws -> JWE {
    
    let keyAndEncryptor = try keyAndEncryptor(
      jweAlgorithm: responseSigningAlg,
      encryptionMethod: responseEncryptionEnc,
      keySet: signingKeySet
    )
    
    let header = try JWEHeader(parameters: [
      "alg": responseSigningAlg.name,
      "enc": responseEncryptionEnc.name,
      "kid": keyAndEncryptor.key.kid
    ])
    
    let d = try data
      .toDictionary()
      .merging([
        JWTClaimNames.issuer: holderId,
        JWTClaimNames.issuedAt: Int(Date().timeIntervalSince1970.rounded())
      ], uniquingKeysWith: { _, new in
        new
      })
    
    let jwe = try JWE(
      header: header,
      payload: Payload(data
        .toDictionary()
        .merging([
          JWTClaimNames.issuer: holderId,
          JWTClaimNames.issuedAt: Int(Date().timeIntervalSince1970.rounded())
        ], uniquingKeysWith: { _, new in
          new
        }).toThrowingJSONData()
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
      signingKeySet: let signingKeySet
    ):
      let keyAndEncryptor = try keyAndEncryptor(
        jweAlgorithm: responseSigningAlg,
        encryptionMethod: responseEncryptionEnc,
        keySet: signingKeySet
      )
      
      let header = try JWEHeader(parameters: [
        "alg": responseSigningAlg.name,
        "enc": responseEncryptionEnc.name
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
    throw ValidatedAuthorizationError.validationError("Unable to create key/encryptor pair")
  }
  
  // swiftlint:disable line_length
  func createEncrypter(
    jweAlgorithm: JWEAlgorithm,
    encryptionMethod: JOSEEncryptionMethod,
    key: WebKeySet.Key
  ) throws -> Encrypter? {
    
    let data = try key.toDictionary().toThrowingJSONData()
    
    guard let keyAlgorithm: KeyManagementAlgorithm = .init(rawValue: jweAlgorithm.name) else {
      throw ValidatedAuthorizationError.validationError("Create encrypter - Unknown key management algorithm")
    }

    guard let contentEncryptionAlgorithm: ContentEncryptionAlgorithm = .init(rawValue: encryptionMethod.name) else {
      throw ValidatedAuthorizationError.validationError("Create encrypter - Unknown content encryption algorithm")
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
      throw ValidatedAuthorizationError.validationError("JWE Algorithm should be of the RSA or ECDH family")
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

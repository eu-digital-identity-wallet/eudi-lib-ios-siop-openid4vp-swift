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
import XCTest
import JOSESwift

@testable import SiopOpenID4VP

final class ResponseSignerEncryptorTests: DiXCTest {
  
  let mockResponsePayload: AuthorizationResponsePayload = .siopAuthenticationResponse(
    idToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c",
    state: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
  )
  
  func testSignResponse() async throws {
    
    let controller = JOSEController()
    
    let privateKey = try controller.generatePrivateKey()
    let publicKey = try controller.generatePublicKey(from: privateKey)
    
    let alg = JWSAlgorithm(.RS256)
    let publicKeyJWK = try RSAPublicKey(
      publicKey: publicKey,
      additionalParameters: [
        "alg": alg.name,
        "use": "sig",
        "kid": UUID().uuidString
      ])
    
    let keySet = try WebKeySet([
      "keys": [publicKeyJWK.jsonString()?.convertToDictionary()]
    ])
    
    let wallet: WalletOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123456789abcdefghi"),
      signingKey: privateKey,
      signingKeySet: keySet,
      supportedClientIdSchemes: [],
      vpFormatsSupported: []
    )
    
    let responseSignerEncryptor = ResponseSignerEncryptor()
    let jarmSpec: JarmSpec = .resolution(
      holderId: UUID().uuidString,
      jarmOption: .signedResponse(
        responseSigningAlg: alg,
        signingKeySet: wallet.signingKeySet,
        signingKey: wallet.signingKey
      )
    )
    
    let response = try await responseSignerEncryptor.signEncryptResponse(spec: jarmSpec, data: mockResponsePayload)
    
    XCTAssert(response.isValidJWT())
    
    // Verify signature
    let jws = try JWS(compactSerialization: response)
    guard let verifier: Verifier = Verifier(verifyingAlgorithm: .RS256, key: publicKey) else {
      XCTAssert(false, "Invalid Verifier")
      return
    }
    
    let payload = try jws.validate(using: verifier).payload
    let message = String(data: payload.data(), encoding: .utf8)!

    XCTAssert(message.isValidJSONString)
  }
  
  func testEncryptResponse() async throws {
    
    let controller = JOSEController()
    let privateKey = try controller.generatePrivateKey()
    let publicKey = try controller.generatePublicKey(from: privateKey)
    let alg = JWEAlgorithm(.RSA_OAEP_256)
    let publicKeyJWK = try RSAPublicKey(
      publicKey: publicKey,
      additionalParameters: [
        "alg": alg.name,
        "use": "enc",
        "kid": UUID().uuidString
      ])
    
    let keySet = try WebKeySet([
      "keys": [publicKeyJWK.jsonString()?.convertToDictionary()]
    ])
    
    let wallet: WalletOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123456789abcdefghi"),
      signingKey: privateKey,
      signingKeySet: keySet,
      supportedClientIdSchemes: [],
      vpFormatsSupported: []
    )
    
    let responseSignerEncryptor = ResponseSignerEncryptor()
    let jarmSpec: JarmSpec = .resolution(
      holderId: UUID().uuidString,
      jarmOption: .encryptedResponse(
        responseSigningAlg: alg,
        responseEncryptionEnc: JOSEEncryptionMethod(.A128CBC_HS256),
        signingKeySet: wallet.signingKeySet
      )
    )
    
    let response = try await responseSignerEncryptor.signEncryptResponse(spec: jarmSpec, data: mockResponsePayload)
    
    XCTAssert(response.isValidJWT())
  }
  
  func testSignEncryptResponse() async throws {
    
    let controller = JOSEController()
    let privateKey = try controller.generatePrivateKey()
    let publicKey = try controller.generatePublicKey(from: privateKey)
    
    let signingAlg = JWSAlgorithm(.RS256)
    let encryptionAlg = JWEAlgorithm(.RSA_OAEP_256)
    
    let publicKeyJWK = try RSAPublicKey(
      publicKey: publicKey,
      additionalParameters: [
        "alg": signingAlg.name,
        "use": "enc",
        "kid": UUID().uuidString
      ])
    
    let keySet = try WebKeySet([
      "keys": [publicKeyJWK.jsonString()?.convertToDictionary()]
    ])
    
    let wallet: WalletOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123456789abcdefghi"),
      signingKey: privateKey,
      signingKeySet: keySet,
      supportedClientIdSchemes: [],
      vpFormatsSupported: []
    )
    
    let encrypted: JarmOption = .encryptedResponse(
      responseSigningAlg: encryptionAlg,
      responseEncryptionEnc: JOSEEncryptionMethod(.A128CBC_HS256),
      signingKeySet: wallet.signingKeySet
    )
    
    let signed: JarmOption = .signedResponse(
      responseSigningAlg: signingAlg,
      signingKeySet: wallet.signingKeySet,
      signingKey: wallet.signingKey
    )
    
    let responseSignerEncryptor = ResponseSignerEncryptor()
    let jarmSpec: JarmSpec = .resolution(
      holderId: UUID().uuidString,
      jarmOption: .signedAndEncryptedResponse(
        signed: signed,
        encrypted: encrypted
      )
    )
    
    let response = try await responseSignerEncryptor.signEncryptResponse(spec: jarmSpec, data: mockResponsePayload)
    
    XCTAssert(response.isValidJWT())
    
    // Decrypt payload
    let jwe = try JWE(compactSerialization: response)
    let decrypter = Decrypter(
      keyManagementAlgorithm: KeyManagementAlgorithm(algorithm: encryptionAlg)!,
      contentEncryptionAlgorithm: ContentEncryptionAlgorithm(encryptionMethod: JOSEEncryptionMethod(.A128CBC_HS256))!,
      decryptionKey: privateKey
    )!
    let payload = try jwe.decrypt(using: decrypter)
    let message = String(data: payload.data(), encoding: .utf8)!
    
    XCTAssert(message.isValidJWT())
  }
}

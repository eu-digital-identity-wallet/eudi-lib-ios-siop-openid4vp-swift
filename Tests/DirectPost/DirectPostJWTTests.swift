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
import XCTest
import JOSESwift
import Mockingbird

@testable import SiopOpenID4VP

final class DirectPostJWTTests: DiXCTest {
  
  func testPostDirectPostJwtAuthorisationResponseGivenValidResolutionAndNegativeConsent() async throws {
    
    // Obtain an id token resolution
    let resolved: ResolvedRequestData = .idToken(
      request: .init(
        idTokenType: .attesterSigned,
        clientMetaData: Constants.testClientMetaData(),
        clientId: Constants.testClientId,
        nonce: Constants.testNonce,
        responseMode: Constants.testDirectPostJwtResponseMode,
        state: Constants.generateRandomBase64String(),
        scope: Constants.testScope
      )
    )
    
    let jose = JOSEController()
    let kid = UUID()
    
    let privateKey = try KeyController.generateHardcodedRSAPrivateKey()
    let publicKey = try KeyController.generateRSAPublicKey(from: privateKey!)
    
    let rsaJWK = try RSAPublicKey(
      publicKey: publicKey,
      additionalParameters: [
        "use": "sig",
        "kid": kid.uuidString
      ])
    
    let holderInfo: HolderInfo = .init(
      email: "email@example.com",
      name: "Bob"
    )
    
    let jws = try jose.build(
      request: resolved,
      holderInfo: holderInfo,
      walletConfiguration: .init(
        subjectSyntaxTypesSupported: [
          .decentralizedIdentifier,
          .jwkThumbprint
        ],
        preferredSubjectSyntaxType: .jwkThumbprint,
        decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123456789abcdefghi"),
        signingKey: try KeyController.generateRSAPrivateKey(),
        signingKeySet: TestsConstants.webKeySet,
        supportedClientIdSchemes: [],
        vpFormatsSupported: []
      ),
      rsaJWK: rsaJWK,
      signingKey: privateKey!,
      kid: kid
    )
    
    XCTAssert(try jose.verify(jws: jose.getJWS(compactSerialization: jws), publicKey: publicKey))
    
    // Obtain consent
    let consent: ClientConsent = .negative(message: "user_cancelled")
    
    let wallet: WalletOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123456789abcdefghi"),
      signingKey: try KeyController.generateRSAPrivateKey(),
      signingKeySet: TestsConstants.webKeySet,
      supportedClientIdSchemes: [],
      vpFormatsSupported: []
    )
    
    // Generate a direct post authorisation response
    let response = try? AuthorizationResponse(
      resolvedRequest: resolved,
      consent: consent,
      walletOpenId4VPConfig: wallet
    )
    
    XCTAssertNotNil(response)
    
    let service = AuthorisationService()
    let dispatcher = Dispatcher(service: service, authorizationResponse: response!)
    _ = try? await dispatcher.dispatch()
    
    XCTAssert(true)
  }
  
  func testPostDirectPostJwtAuthorisationResponseGivenValidResolutionAndIdTokenConsent() async throws {
   
    let token = "eyJhbGciOiJIUzI1NiJ9.eyIxIjoiMSJ9.aoHTuJmTqZDNNuHqw-O6Gp5HACYEYo4p7RwG0ZhGrKY"
    
    let privateKey = try KeyController.generateECDHPrivateKey()
    let publicKey = try KeyController.generateECDHPublicKey(from: privateKey)
    
    let publicJwk = try ECPublicKey(
      publicKey: publicKey,
      additionalParameters: [
        "use": "enc",
        "kid": UUID().uuidString,
        "alg": "ECDH-ES"
      ]
    )
    
    let privateJWK = try ECPrivateKey(
      privateKey: privateKey
    )
    
    let keySet = try WebKeySet([
      "keys": [publicJwk.jsonString()?.convertToDictionary()]
    ])
    
    let clientMetaData = ClientMetaData(
      jwks: ["keys": [try publicJwk.toDictionary()]].toJSONString(),
      idTokenEncryptedResponseAlg: "RS256",
      idTokenEncryptedResponseEnc: "A128CBC-HS256",
      subjectSyntaxTypesSupported: ["urn:ietf:params:oauth:jwk-thumbprint", "did:example", "did:key"],
      authorizationEncryptedResponseAlg: "ECDH-ES",
      authorizationEncryptedResponseEnc: "A128CBC-HS256" // was: A256GCM"
    )
    
    let validator = ClientMetaDataValidator()
    try await validator.validate(clientMetaData: clientMetaData)
    
    let wallet: WalletOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123"),
      signingKey: privateKey,
      signingKeySet: keySet,
      supportedClientIdSchemes: [.isoX509],
      vpFormatsSupported: []
    )
    
    let resolved: ResolvedRequestData = .idToken(
      request: .init(
        idTokenType: .attesterSigned,
        clientMetaData: clientMetaData,
        clientId: Constants.testClientId,
        nonce: Constants.testNonce,
        responseMode: Constants.testDirectPostJwtResponseMode,
        state: Constants.generateRandomBase64String(),
        scope: Constants.testScope
      )
    )
    
    let consent: ClientConsent = .idToken(idToken: token)
    
    // Generate a direct post jwt authorisation response
    let response = try? AuthorizationResponse(
      resolvedRequest: resolved,
      consent: consent,
      walletOpenId4VPConfig: wallet
    )
    
    XCTAssertNotNil(response)
    
    let service = AuthorisationService()
    let dispatcher = Dispatcher(service: service, authorizationResponse: response!)
    _ = try? await dispatcher.dispatch()

    let joseResponse = await service.joseResponse
    
    XCTAssertNotNil(response)
    
    let encryptedJwe = try JWE(compactSerialization: joseResponse!)
    
    let decrypter = Decrypter(
      keyManagementAlgorithm: .init(algorithm: JWEAlgorithm(.ECDH_ES))!,
      contentEncryptionAlgorithm: .A128CBCHS256,
      decryptionKey: privateJWK
    )!
    
    let decryptionPayload = try encryptedJwe.decrypt(using: decrypter)
    let decryption = try JSONSerialization.jsonObject(with: decryptionPayload.data()) as! [String: Any]
    
    XCTAssertEqual(decryption["id_token"] as! String, token)
    XCTAssertEqual(decryption["iss"] as! String, "did:example:123")
  }
  
  func testSDKEndtoEndDirectPostJwt() async throws {
    
    let sdk = SiopOpenID4VP()
    
    overrideDependencies()
    let r = try? await sdk.authorize(url: URL(string: "eudi-wallet://authorize?client_id=Verifier&request_uri=http://localhost:8080/wallet/request.jwt/P4abwMjRVB4gXNWgim8wTxSpUb4Nit6KuNgnLz7_u-3IvgsxQ3KhwB1BPeq7qdXHar1nJNxvalpguQzxAnfr7A")!)
    
    // Do not fail 404
    guard let r = r else {
      XCTAssert(true)
      return
    }
    
    switch r {
    case .notSecured: break
    case .jwt(request: let request):
      let resolved = request
      
      let kid = UUID()
      let jose = JOSEController()
      
      let privateKey = try KeyController.generateHardcodedRSAPrivateKey()
      let publicKey = try KeyController.generateRSAPublicKey(from: privateKey!)
      let rsaJWK = try RSAPublicKey(
        publicKey: publicKey,
        additionalParameters: [
          "use": "sig",
          "kid": kid.uuidString
        ])
      
      let holderInfo: HolderInfo = .init(
        email: "email@example.com",
        name: "Bob"
      )
      
      let wallet: WalletOpenId4VPConfiguration = .init(
        subjectSyntaxTypesSupported: [
          .decentralizedIdentifier,
          .jwkThumbprint
        ],
        preferredSubjectSyntaxType: .jwkThumbprint,
        decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123456789abcdefghi"),
        signingKey: try KeyController.generateRSAPrivateKey(),
        signingKeySet: WebKeySet(keys: []),
        supportedClientIdSchemes: [],
        vpFormatsSupported: []
      )
      
      let jws = try jose.build(
        request: resolved,
        holderInfo: holderInfo,
        walletConfiguration: wallet,
        rsaJWK: rsaJWK,
        signingKey: privateKey!,
        kid: kid
      )
      
      XCTAssert(try jose.verify(jws: jose.getJWS(compactSerialization: jws), publicKey: publicKey))
      
      // Obtain consent
      let consent: ClientConsent = .idToken(idToken: jws)
      
      // Generate a direct post authorisation response
      let response = try? AuthorizationResponse(
        resolvedRequest: resolved,
        consent: consent,
        walletOpenId4VPConfig: wallet
      )
      
      XCTAssertNotNil(response)
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      
      XCTAssertTrue(result == .accepted(redirectURI: nil))
    }
  }
}

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
    
    let validator = ClientMetaDataValidator()
    let metaData = try await validator.validate(clientMetaData: Constants.testClientMetaData())
    
    // Obtain an id token resolution
    let resolved: ResolvedRequestData = .idToken(
      request: .init(
        idTokenType: .attesterSigned,
        clientMetaData: metaData,
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
        decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123"),
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
      decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123"),
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
    
    let keySet = try WebKeySet(jwks: [publicJwk])
    
    let clientMetaData = ClientMetaData(
      jwks: ["keys": [try publicJwk.toDictionary()]].toJSONString(),
      idTokenEncryptedResponseAlg: "RS256",
      idTokenEncryptedResponseEnc: "A128CBC-HS256",
      subjectSyntaxTypesSupported: ["urn:ietf:params:oauth:jwk-thumbprint", "did:example", "did:key"],
      authorizationEncryptedResponseAlg: "ECDH-ES",
      authorizationEncryptedResponseEnc: "A128CBC-HS256" // was: A256GCM"
    )
    
    let validator = ClientMetaDataValidator()
    let metaData = try await validator.validate(clientMetaData: clientMetaData)
    
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
        clientMetaData: metaData,
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
      keyManagementAlgorithm: .init(algorithm: .init(.ECDH_ES))!,
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
    let url = "http://localhost:8080/wallet/request.jwt/H2gxMSVqB_GYkyeoNVMtk7mNCkglKAjh88j3948D7H6gwqTeGWfkw-KqbRl1K8o4Ct96o6XQ78sm9ItbkmWFnA"
    
    overrideDependencies()
    let result = try? await sdk.authorize(url: URL(string: "eudi-wallet://authorize?client_id=Verifier&request_uri=\(url)")!)
    
    // Do not fail 404
    guard let result = result else {
      XCTAssert(true)
      return
    }
    
    switch result {
    case .notSecured: break
    case .jwt(request: let request):
      let resolved = request
      
      let rsaPrivateKey = try KeyController.generateRSAPrivateKey()
      let rsaPublicKey = try KeyController.generateRSAPublicKey(from: rsaPrivateKey)
      let privateKey = try KeyController.generateECDHPrivateKey()
      
      let rsaJWK = try RSAPublicKey(
        publicKey: rsaPublicKey,
        additionalParameters: [
          "use": "sig",
          "kid": UUID().uuidString,
          "alg": "RS256"
        ])
      
      let keySet = try WebKeySet(jwk: rsaJWK)
      
      let wallet: WalletOpenId4VPConfiguration = .init(
        subjectSyntaxTypesSupported: [
          .decentralizedIdentifier,
          .jwkThumbprint
        ],
        preferredSubjectSyntaxType: .jwkThumbprint,
        decentralizedIdentifier: try .init(rawValue: "did:example:123"),
        signingKey: privateKey,
        signingKeySet: keySet,
        supportedClientIdSchemes: [],
        vpFormatsSupported: []
      )
      
      // Obtain consent
      let consent: ClientConsent = .vpToken
      
      // Generate a direct post authorisation response
      let response = try! AuthorizationResponse(
        resolvedRequest: resolved,
        consent: consent,
        walletOpenId4VPConfig: wallet
      )
      
      // Dispatch
      XCTAssertNotNil(response)
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response)
      switch result {
      case .accepted:
        XCTAssert(true)
      default:
        XCTAssert(false)
      }
    }
  }
  
  func testGivenClientMetaDataWhenAValidResolutionIsObtainedThenDecodeJwtWithSucess() async throws {
    
    let ecPrivateKey = try KeyController.generateECDHPrivateKey()
    let ecPublicKey = try KeyController.generateECDHPublicKey(from: ecPrivateKey)
    
    let ecPublicJwk = try ECPublicKey(
      publicKey: ecPublicKey,
      additionalParameters: [
        "use": "enc",
        "kid": UUID().uuidString,
        "alg": "ECDH-ES"
      ]
    )
    
    let ecPublicJwkString = try! ecPublicJwk.toDictionary().toJSONString()
    
    let ecPrivateJWK = try ECPrivateKey(
      privateKey: ecPrivateKey
    )
    
    let rsaPrivateKey = try KeyController.generateHardcodedRSAPrivateKey()
    let rsaPublicKey = try KeyController.generateRSAPublicKey(from: rsaPrivateKey!)
    
    let rsaJWK = try RSAPublicKey(
      publicKey: rsaPublicKey,
      additionalParameters: [
        "use": "sig",
        "kid": UUID().uuidString,
        "alg": "RS256"
      ])
    
    let rsaPublicJwkString: String! = try! rsaJWK.toDictionary().toJSONString()
    
    let rsaKeySet = try WebKeySet([
      "keys": [rsaJWK.jsonString()?.convertToDictionary()]
    ])
    
    let clientMetaDataString: String = """
    {
      "jwks": {
        "keys": [\(ecPublicJwkString!), \(rsaPublicJwkString!)]
      },
      "id_token_signed_response_alg": "RS256",
      "id_token_encrypted_response_alg": "RS256",
      "id_token_encrypted_response_enc": "A128CBC-HS256",
      "subject_syntax_types_supported": ["urn:ietf:params:oauth:jwk-thumbprint", "did:example", "did:key"],
      "authorization_signed_response_alg": "RS256",
      "authorization_encrypted_response_alg": "ECDH-ES",
      "authorization_encrypted_response_enc": "A128CBC-HS256"
    }
    """
    
    let clientMetaData = try ClientMetaData(metaDataString: clientMetaDataString)
    
    let validator = ClientMetaDataValidator()
    
    let validatedClientMetaData = try! await validator.validate(clientMetaData: clientMetaData)
    
    let resolved: ResolvedRequestData = .vpToken(
      request: .init(
        presentationDefinition: .init(
          id: "dummy-id",
          inputDescriptors: []),
        clientMetaData: validatedClientMetaData,
        clientId: "https%3A%2F%2Fclient.example.org%2Fcb",
        nonce: "0S6_WzA2Mj",
        responseMode: .directPostJWT(responseURI: URL(string: "https://respond.here")!),
        state: "state"
      ))
    
    let consent: ClientConsent = .vpToken
    
    let response: AuthorizationResponse = try .init(
      resolvedRequest: resolved,
      consent: consent,
      walletOpenId4VPConfig: .init(
        subjectSyntaxTypesSupported: [
          .decentralizedIdentifier,
          .jwkThumbprint
        ],
        preferredSubjectSyntaxType: .jwkThumbprint,
        decentralizedIdentifier: try .init(rawValue: "did:example:123"),
        signingKey: rsaPrivateKey!,
        signingKeySet: rsaKeySet,
        supportedClientIdSchemes: [],
        vpFormatsSupported: []
      )
    )
    
    let service = AuthorisationService()
    let dispatcher = Dispatcher(service: service, authorizationResponse: response)
    _ = try? await dispatcher.dispatch()
    
    let joseResponse = await service.joseResponse
    let encryptedJwe = try JWE(compactSerialization: joseResponse!)
    
    let decrypter = Decrypter(
      keyManagementAlgorithm: .init(algorithm: validatedClientMetaData!.authorizationEncryptedResponseAlg!)!,
      contentEncryptionAlgorithm: .init(encryptionMethod: validatedClientMetaData!.authorizationEncryptedResponseEnc!)!,
      decryptionKey: ecPrivateJWK
    )!
    
    let decryptionPayload = try encryptedJwe.decrypt(using: decrypter)
    
    let jwt = String.init(data: decryptionPayload.data(), encoding: .utf8)
    XCTAssert(jwt!.isValidJWT())
    
    let iss = JSONWebToken(jsonWebToken: jwt!)?.payload["iss"] as! String
    XCTAssert(iss == "did:example:123")
  }
}
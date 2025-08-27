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

@testable import SiopOpenID4VP

final class DirectPostJWTTests: DiXCTest {
  
  func testSDKEndtoEndWebVerifierDirectPostJwtPreregistered() async throws {
    
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
    let publicKeysURL = URL(string: "\(TestsConstants.host)/wallet/public-keys.json")!
    let wallet: SiopOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try .init(rawValue: "did:example:123"),
      privateKey: privateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .preregistered(clients: [
          TestsConstants.testClientId: .init(
            clientId: TestsConstants.testClientId,
            legalName: "Verifier",
            jarSigningAlg: .init(.RS256),
            jwkSetSource: .fetchByReference(url: publicKeysURL)
          )
        ]),
        .x509SanDns(trust: { _ in
          true
        })
      ],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .default()
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
    
    /// To get this URL, visit https://dev.verifier.eudiw.dev/
    /// and  "Request for the entire PID"
    /// Copy the "Authenticate with wallet link", choose the value for "request_uri"
    /// Decode the URL online and paste it below in the url variable
    /// Note:  The url is only valid for one use
    let url = "#04"
    
    overrideDependencies()
    let result = await sdk.authorize(
      url: URL(
        string: url
      )!
    )
    
    switch result {
    case .jwt(request: let request):
      // Obtain consent
      let consent: ClientConsent = .vpToken(
        vpContent: .dcql(verifiablePresentations: [
          try QueryId(value: "query_0"): [.generic(TestsConstants.cbor)]
        ])
      )
      
      // Generate a direct post authorisation response
      let response = try? XCTUnwrap(AuthorizationResponse(
        resolvedRequest: request,
        consent: consent,
        walletOpenId4VPConfig: wallet
      ), "Expected item to be non-nil")
      
      // Dispatch
      XCTAssertNotNil(response)
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      switch result {
      case .accepted:
        XCTAssert(true)
      default:
        XCTAssert(false)
      }
    default:
      XCTExpectFailure()
      XCTAssert(false)
    }
  }
  
  func testSDKEndtoEndWebVerifierDirectPostJwtRedirectUrl() async throws {
    
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
    let wallet: SiopOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try .init(rawValue: "did:example:123"),
      privateKey: privateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .redirectUri,
        .x509SanDns(trust: { _ in
          true
        })
      ],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .encryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .default()
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
    
    /// To get this URL, visit https://dev.verifier.eudiw.dev/
    /// and  "Request for the entire PID"
    /// Copy the "Authenticate with wallet link", choose the value for "request_uri"
    /// Decode the URL online and paste it below in the url variable
    /// Note:  The url is only valid for one use
    let url = "#08"
    
    overrideDependencies()
    let result = await sdk.authorize(
      url: .init(
        string: url
      )!
    )
    
    switch result {
    case .jwt(request: let request):
      // Obtain consent
      let consent: ClientConsent = .vpToken(
        vpContent: .dcql(verifiablePresentations: [
          try QueryId(value: "query_0"): [.generic(TestsConstants.cbor)]
        ])
      )
      
      // Generate a direct post authorisation response
      let response = try? XCTUnwrap(AuthorizationResponse(
        resolvedRequest: request,
        consent: consent,
        walletOpenId4VPConfig: wallet
      ), "Expected item to be non-nil")
      
      // Dispatch
      XCTAssertNotNil(response)
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      switch result {
      case .accepted:
        XCTAssert(true)
      default:
        XCTAssert(false)
      }
    default:
      XCTExpectFailure()
      XCTAssert(false)
    }
  }
  
  func testSDKEndtoEndDirectPostJwtWithUrlPreregistered() async throws {
    
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
    let publicKeysURL = URL(string: "\(TestsConstants.host)/wallet/public-keys.json")!
    let wallet: SiopOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try .init(rawValue: "did:example:123"),
      privateKey: privateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .preregistered(clients: [
          TestsConstants.testClientId: .init(
            clientId: TestsConstants.testClientId,
            legalName: "Verifier",
            jarSigningAlg: .init(.RS256),
            jwkSetSource: .fetchByReference(url: publicKeysURL)
          )
        ])
      ],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .default()
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
    // Add your own URL here that you can obtain from
    // https://dev.verifier.eudiw.dev/
    let url = "#07"
    
    overrideDependencies()
    let result = await sdk.authorize(
      url: URL(
        string: url
      )!
    )
    
    switch result {
    case .jwt(let request):
      // Obtain consent
      let consent: ClientConsent = .vpToken(
        vpContent: .dcql(verifiablePresentations: [
          try QueryId(value: "query_0"): [.generic(TestsConstants.cbor)]
        ])
      )
      
      // Generate a direct post authorisation response
      let response = try? XCTUnwrap(AuthorizationResponse(
        resolvedRequest: request,
        consent: consent,
        walletOpenId4VPConfig: wallet
      ), "Expected item to be non-nil")
      
      // Dispatch
      XCTAssertNotNil(response)
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      switch result {
      case .accepted:
        XCTAssert(true)
      default:
        XCTAssert(false)
      }
    default:
      XCTExpectFailure()
      XCTAssert(false)
    }
  }
  
  func testPostDirectPostJwtAuthorisationResponseGivenValidResolutionAndNegativeConsent() async throws {
    
    let validator = ClientMetaDataValidator()
    let metaData = try await validator.validate(
      clientMetaData: Constants.testClientMetaData(),
      responseMode: nil,
      responseEncryptionConfiguration: .unsupported
    )
    
    // Obtain an id token resolution
    let resolved: ResolvedRequestData = .idToken(
      request: .init(
        idTokenType: .attesterSigned,
        presentationQuery: .byDigitalCredentialsQuery(
          try! .init(credentials: [
            .init(
              id: .init(value: "query_0"),
              format: .init(format: "sd-jwt"),
              meta: [:]
            )
          ])
        ),
        clientMetaData: metaData,
        client: Constants.testClient,
        nonce: Constants.testNonce,
        responseMode: Constants.testDirectPostJwtResponseMode,
        state: Constants.generateRandomBase64String(),
        scope: Constants.testScope,
        responseEncryptionSpecification: nil
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
        privateKey: privateKey!,
        publicWebKeySet: TestsConstants.webKeySet,
        supportedClientIdSchemes: [],
        vpFormatsSupported: ClaimFormat.default(),
        vpConfiguration: .default(),
        responseEncryptionConfiguration: .unsupported
      ),
      rsaJWK: rsaJWK,
      signingKey: privateKey!,
      kid: kid
    )
    
    XCTAssert(try jose.verify(jws: jose.getJWS(compactSerialization: jws), publicKey: publicKey))
    
    // Obtain consent
    let consent: ClientConsent = .negative(message: "user_cancelled")
    
    let wallet: SiopOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123"),
      privateKey: try KeyController.generateRSAPrivateKey(),
      publicWebKeySet: TestsConstants.webKeySet,
      supportedClientIdSchemes: [],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .default()
    )
    
    // Generate a direct post authorisation response
    let response = try? AuthorizationResponse(
      resolvedRequest: resolved,
      consent: consent,
      walletOpenId4VPConfig: wallet
    )
    
    XCTAssertNil(response)
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
      vpFormatsSupported: TestsConstants.testVpFormatsSupportedTO()
    )
    
    let validator = ClientMetaDataValidator()
    let metaData = try await validator.validate(
      clientMetaData: clientMetaData,
      responseMode: nil,
      responseEncryptionConfiguration: .unsupported
    )
    
    let wallet: SiopOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123"),
      privateKey: privateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .default()
    )
    
    let resolved: ResolvedRequestData = .idToken(
      request: .init(
        idTokenType: .attesterSigned,
        presentationQuery: .byDigitalCredentialsQuery(
          try! .init(credentials: [
            .init(
              id: .init(value: "query_0"),
              format: .init(format: "sd-jwt"),
              meta: [:]
            )
          ])
        ),
        clientMetaData: metaData,
        client: Constants.testClient,
        nonce: Constants.testNonce,
        responseMode: Constants.testDirectPostJwtResponseMode,
        state: Constants.generateRandomBase64String(),
        scope: Constants.testScope,
        responseEncryptionSpecification: .init(
          responseEncryptionAlg: .init(.ECDH_ES),
          responseEncryptionEnc: .init(.A128CBC_HS256),
          clientKey: keySet
        )
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
  }
  
  func testSDKEndtoEndDirectPostJwtPreregistered() async throws {
    
    let nonce = UUID().uuidString
    let session = try? await TestsHelpers.getDirectPostJwtSession(nonce: nonce)
    
    guard let session = session else {
      XCTExpectFailure("this tests depends on a local verifier running")
      XCTAssert(false)
      return
    }
    
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
    let publicKeysURL = URL(string: "\(TestsConstants.host)/wallet/public-keys.json")!
    let wallet: SiopOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try .init(rawValue: "did:example:123"),
      privateKey: privateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .preregistered(clients: [
          TestsConstants.testClientId: .init(
            clientId: TestsConstants.testClientId,
            legalName: "Verifier",
            jarSigningAlg: .init(.RS256),
            jwkSetSource: .fetchByReference(url: publicKeysURL)
          )
        ])
      ],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .default()
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
    let url = session["request_uri"]
    let clientId = session["client_id"]
    let transactionId = session["transaction_id"] as! String
    
    overrideDependencies()
    let result = await sdk.authorize(
      url: URL(
        string: "eudi-wallet://authorize?client_id=\(clientId!)&request_uri=\(url!)"
      )!
    )
    
    switch result {
    case .jwt(request: let request):
      // Obtain consent
      let consent: ClientConsent = .vpToken(
        vpContent: .dcql(verifiablePresentations: [
          try QueryId(value: "query_0"): [.generic(TestsConstants.cbor)]
        ])
      )
      
      // Generate a direct post authorisation response
      let response = try? XCTUnwrap(AuthorizationResponse(
        resolvedRequest: request,
        consent: consent,
        walletOpenId4VPConfig: wallet
      ), "Expected item to be non-nil")
      
      // Dispatch
      XCTAssertNotNil(response)
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      switch result {
      case .accepted:
        XCTAssert(true)
      default:
        XCTAssert(false)
      }
      
      let pollingResult = try await TestsHelpers.pollVerifier(
        transactionId: transactionId,
        nonce: nonce
      )
      
      switch pollingResult {
      case .success:
        XCTAssert(true)
      case .failure:
        XCTAssert(false)
      }
    default:
      XCTAssert(false)
    }
  }
  
  func testSDKEndtoEndDirectPostJwtX509WithRemovedSchemeWithSdJwt() async throws {
    
    let nonce = TestsConstants.testNonce
    let session = try? await TestsHelpers.getDirectPostJwtSession(
      nonce: nonce
    )
    
    guard let session = session else {
      XCTExpectFailure("this tests depends on a local verifier running")
      XCTAssert(false)
      return
    }
    
    let rsaPrivateKey = try KeyController.generateRSAPrivateKey()
    let rsaPublicKey = try KeyController.generateRSAPublicKey(from: rsaPrivateKey)
    
    let rsaJWK = try RSAPublicKey(
      publicKey: rsaPublicKey,
      additionalParameters: [
        "use": "sig",
        "kid": UUID().uuidString,
        "alg": "RS256"
      ])
    
    let chainVerifier = { certificates in
      let chainVerifier = X509CertificateChainVerifier()
      let verified = try? chainVerifier.verifyCertificateChain(
        base64Certificates: certificates
      )
      return chainVerifier.isChainTrustResultSuccesful(verified ?? .failure)
    }
    
    let keySet = try WebKeySet(jwk: rsaJWK)
    let wallet: SiopOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try .init(rawValue: "did:example:123"),
      privateKey: rsaPrivateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .x509SanDns(trust: chainVerifier)
      ],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .default()
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
    let url = session["request_uri"]
    let clientId = session["client_id"]!
    let transactionId = session["transaction_id"] as! String
    
    overrideDependencies()
    let result = await sdk.authorize(
      url: URL(
        string: "eudi-wallet://authorize?client_id=\(clientId)&request_uri=\(url!)"
      )!
    )
    
    switch result {
    case .jwt(let request):
      let resolved = request
      
      var presentation: String?
      switch resolved {
      case .vpToken(let request):
        
        presentation = TestsConstants.sdJwtPresentations(
          transactiondata: request.transactionData,
          clientID: request.client.id.originalClientId,
          nonce: TestsConstants.testNonce,
          useSha3: false
        )
        
      default:
        XCTFail("Incorrectly resolved")
      }
      
      // Obtain consent
      let consent: ClientConsent = .vpToken(
        vpContent: .dcql(verifiablePresentations: [
          try QueryId(value: "query_0"): [.generic(presentation!)]
        ])
      )
      
      // Generate a direct post authorisation response
      let response = try? XCTUnwrap(AuthorizationResponse(
        resolvedRequest: request,
        consent: consent,
        walletOpenId4VPConfig: wallet
      ), "Expected item to be non-nil")
      
      // Dispatch
      XCTAssertNotNil(response)
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      switch result {
      case .accepted:
        XCTAssert(true)
      default:
        XCTExpectFailure("Please make sure you have a valid sd-jwt with a valid key binding jwt")
        XCTAssert(false)
        return
      }
      
      let pollingResult = try await TestsHelpers.pollVerifier(
        transactionId: transactionId,
        nonce: nonce
      )
      
      switch pollingResult {
      case .success:
        XCTAssert(true)
      case .failure:
        XCTAssert(false)
      }
    default:
      XCTAssert(false)
    }
  }
  
  func testSDKEndtoEndWebVerifierDirectPostJwtX509WithAccepetedRequestURI() async throws {
    
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
    
    let chainVerifier = { certificates in
      let chainVerifier = X509CertificateChainVerifier()
      let verified = try? chainVerifier.verifyCertificateChain(
        base64Certificates: certificates
      )
      return chainVerifier.isChainTrustResultSuccesful(verified ?? .failure)
    }
    
    let keySet = try WebKeySet(jwk: rsaJWK)
    let wallet: SiopOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try .init(rawValue: "did:example:123"),
      privateKey: privateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .x509SanDns(trust: chainVerifier)
      ],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .encryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .default()
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
    
    /// To get this URL, visit https://dev.verifier.eudiw.dev/
    /// and  "Request for the entire PID"
    /// Copy the "Authenticate with wallet link", choose the value for "request_uri"
    /// Decode the URL online and paste it below in the url variable
    /// Note:  The url is only valid for one use
    let url = "eudi-openid4vp://?client_id=x509_san_dns%3Adev.verifier-backend.eudiw.dev&request_uri=https%3A%2F%2Fdev.verifier-backend.eudiw.dev%2Fwallet%2Frequest.jwt%2F5KFaGjykbMRqgLcomBDekRzN0bJKVYg_HLbDbaMiFDemz6mcU7OZU4AzHCstL0nNvxmY33al9UzkLEEwJOjP7g&request_uri_method=post"
    
    overrideDependencies()
    let result = await sdk.authorize(
      url: URL(
        string: url
      )!
    )
    
    switch result {
    case .jwt(let request):
      
      var presentation: String?
      switch request {
      case .vpToken(let request):
        
        presentation = TestsConstants.sdJwtPresentations(
          transactiondata: request.transactionData,
          clientID: request.client.id.originalClientId,
          nonce: TestsConstants.testNonce,
          useSha3: false
        )
        
      default:
        XCTFail("Incorrectly resolved")
      }
      
      // Obtain consent
      let consent: ClientConsent = .vpToken(
        vpContent: .dcql(verifiablePresentations: [
          try QueryId(value: "query_0"): [.generic(presentation!)]
        ])
      )
      
      // Generate a direct post authorisation response
      let response = try? XCTUnwrap(AuthorizationResponse(
        resolvedRequest: request,
        consent: consent,
        walletOpenId4VPConfig: wallet
      ), "Expected item to be non-nil")
      
      // Dispatch
      XCTAssertNotNil(response)
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      switch result {
      case .accepted(let redirectURI):
        XCTAssert(true, redirectURI?.absoluteString ?? "No redirect url")
      default:
        XCTAssert(false)
      }
    default:
      XCTExpectFailure()
      XCTAssert(false)
    }
  }
  
  func testSDKEndtoEndDirectPostJwtX509() async throws {
    
    let nonce = UUID().uuidString
    let session = try? await TestsHelpers.getDirectPostJwtSession(nonce: nonce)
    
    guard let session = session else {
      XCTExpectFailure("this tests depends on a local verifier running")
      XCTAssert(false)
      return
    }
    
    let rsaPrivateKey = try KeyController.generateRSAPrivateKey()
    let rsaPublicKey = try KeyController.generateRSAPublicKey(
      from: rsaPrivateKey
    )
    
    let rsaJWK = try RSAPublicKey(
      publicKey: rsaPublicKey,
      additionalParameters: [
        "use": "sig",
        "kid": UUID().uuidString,
        "alg": "RS256"
      ])
    
    let chainVerifier = { certificates in
      let chainVerifier = X509CertificateChainVerifier()
      let verified = try? chainVerifier.verifyCertificateChain(
        base64Certificates: certificates
      )
      return chainVerifier.isChainTrustResultSuccesful(verified ?? .failure)
    }
    
    let keySet = try WebKeySet(jwk: rsaJWK)
    let wallet: SiopOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try .init(
        rawValue: "did:example:123"
      ),
      privateKey: rsaPrivateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .x509SanDns(trust: chainVerifier)
      ],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .default()
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
    let url = session["request_uri"]
    let clientId = session["client_id"]
    let transactionId = session["transaction_id"] as! String
    
    overrideDependencies()
    let result = await sdk.authorize(
      url: URL(
        string: "eudi-wallet://authorize?client_id=\(clientId!)&request_uri=\(url!)"
      )!
    )
    
    switch result {
    case .jwt(let request):
      // Obtain consent
      let consent: ClientConsent = .vpToken(
        vpContent: .dcql(verifiablePresentations: [
          try QueryId(value: "query_0"): [.generic(TestsConstants.cbor)]
        ])
      )
      
      // Generate a direct post authorisation response
      let response = try? XCTUnwrap(AuthorizationResponse(
        resolvedRequest: request,
        consent: consent,
        walletOpenId4VPConfig: wallet
      ), "Expected item to be non-nil")
      
      // Dispatch
      XCTAssertNotNil(response)
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      switch result {
      case .accepted:
        XCTAssert(true)
      default:
        XCTAssert(false)
      }
      
      let pollingResult = try await TestsHelpers.pollVerifier(
        transactionId: transactionId,
        nonce: nonce
      )
      
      switch pollingResult {
      case .success:
        XCTAssert(true)
      case .failure:
        XCTAssert(false)
      }
    default:
      XCTAssert(false)
    }
  }
  
  func testSDKEndtoEndDirectPostJwtX509WithTransactionData() async throws {
    
    let nonce = TestsConstants.testNonce
    let session = try? await TestsHelpers.getDirectPostJwtSession(
      nonce: nonce,
      format: "dc+sd-jwt",
      transactionData: [
        TransactionData.json(
          type: try .init(value: "authorization"),
          credentialIds: [
            try .init(value: "query_0")
          ]
        )
      ]
    )
    
    guard let session = session else {
      XCTExpectFailure("this tests depends on a local verifier running")
      XCTAssert(false)
      return
    }
    
    let rsaPrivateKey = try KeyController.generateRSAPrivateKey()
    let rsaPublicKey = try KeyController.generateRSAPublicKey(
      from: rsaPrivateKey
    )
    
    let rsaJWK = try RSAPublicKey(
      publicKey: rsaPublicKey,
      additionalParameters: [
        "use": "sig",
        "kid": UUID().uuidString,
        "alg": "RS256"
      ])
    
    let chainVerifier = { certificates in
      let chainVerifier = X509CertificateChainVerifier()
      let verified = try? chainVerifier.verifyCertificateChain(
        base64Certificates: certificates
      )
      return chainVerifier.isChainTrustResultSuccesful(verified ?? .failure)
    }
    
    let keySet = try WebKeySet(jwk: rsaJWK)
    let wallet: SiopOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try .init(rawValue: "did:example:123"),
      privateKey: rsaPrivateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .x509SanDns(trust: chainVerifier)
      ],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .default()
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
    let url = session["request_uri"]
    guard let clientId = session["client_id"] else {
      XCTAssert(false, "Found nil client id")
      return
    }
    
    let transactionId = session["transaction_id"] as! String
    
    overrideDependencies()
    let result = await sdk.authorize(
      url: URL(
        string: "eudi-wallet://authorize?client_id=\(clientId)&request_uri=\(url!)"
      )!
    )
    
    switch result {
    case .jwt(let request):
      let resolved = request
      
      var presentation: String?
      switch resolved {
      case .vpToken(let request):
        let transactionData = request.transactionData!.first
        let type = try! transactionData!.type()
        let credentialId = try! transactionData!.credentialIds().first
        
        XCTAssertEqual(type.value, "authorization")
        XCTAssertEqual(credentialId!.value, "query_0")
        
        presentation = TestsConstants.sdJwtPresentations(
          transactiondata: request.transactionData,
          clientID: request.client.id.originalClientId,
          nonce: request.nonce,
          useSha3: false
        )
        
      default:
        XCTFail("Incorrectly resolved")
      }
      
      // Obtain consent
      let consent: ClientConsent = .vpToken(
        vpContent: .dcql(verifiablePresentations: [
          try QueryId(value: "query_0"): [
            .generic(presentation!)
          ]
        ])
      )
      
      // Generate a direct post authorisation response
      let response = try? XCTUnwrap(AuthorizationResponse(
        resolvedRequest: request,
        consent: consent,
        walletOpenId4VPConfig: wallet
      ), "Expected item to be non-nil")
      
      // Dispatch
      XCTAssertNotNil(response)
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      switch result {
      case .accepted:
        XCTAssert(true)
      default:
        XCTAssert(false)
      }
      
      let pollingResult = try await TestsHelpers.pollVerifier(
        transactionId: transactionId,
        nonce: nonce
      )
      
      switch pollingResult {
      case .success:
        XCTAssert(true)
      case .failure:
        XCTAssert(false)
      }
    default:
      XCTAssert(false)
    }
  }
  
  func testSDKEndtoEndDirectPostJwtX509WithRemovedScheme() async throws {
    
    let nonce = UUID().uuidString
    let session = try? await TestsHelpers.getDirectPostJwtSession(nonce: nonce)
    
    guard let session = session else {
      XCTExpectFailure("this tests depends on a local verifier running")
      XCTAssert(false)
      return
    }
    
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
    
    let chainVerifier = { certificates in
      let chainVerifier = X509CertificateChainVerifier()
      let verified = try? chainVerifier.verifyCertificateChain(
        base64Certificates: certificates
      )
      return chainVerifier.isChainTrustResultSuccesful(verified ?? .failure)
    }
    
    let keySet = try WebKeySet(jwk: rsaJWK)
    let wallet: SiopOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try .init(rawValue: "did:example:123"),
      privateKey: privateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .x509SanDns(trust: chainVerifier)
      ],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .default()
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
    let url = session["request_uri"]
    let clientId = session["client_id"]!
    let transactionId = session["transaction_id"] as! String
    
    overrideDependencies()
    let result = await sdk.authorize(
      url: URL(
        string: "eudi-wallet://authorize?client_id=\(clientId)&request_uri=\(url!)"
      )!
    )
    
    switch result {
    case .jwt(let request):
      // Obtain consent
      let consent: ClientConsent = .vpToken(
        vpContent: .dcql(verifiablePresentations: [
          try QueryId(value: "query_0"): [.generic(TestsConstants.cbor)]
        ])
      )
      
      // Generate a direct post authorisation response
      let response = try? XCTUnwrap(AuthorizationResponse(
        resolvedRequest: request,
        consent: consent,
        walletOpenId4VPConfig: wallet
      ), "Expected item to be non-nil")
      
      // Dispatch
      XCTAssertNotNil(response)
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      switch result {
      case .accepted:
        XCTAssert(true)
      default:
        XCTAssert(false)
      }
      
      let pollingResult = try await TestsHelpers.pollVerifier(
        transactionId: transactionId,
        nonce: nonce
      )
      
      switch pollingResult {
      case .success:
        XCTAssert(true)
      case .failure:
        XCTAssert(false)
      }
    default:
      XCTAssert(false)
    }
  }
  
  func testSDKEndtoEndDirectPostJwtX509WithRemovedSchemeAndExpectedInvalid() async throws {
    
    let nonce = UUID().uuidString
    let session = try? await TestsHelpers.getDirectPostJwtSession(nonce: nonce)
    
    guard let session = session else {
      XCTExpectFailure("this tests depends on a local verifier running")
      XCTAssert(false)
      return
    }
    
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
    
    let chainVerifier = { certificates in
      let chainVerifier = X509CertificateChainVerifier()
      let verified = try? chainVerifier.verifyCertificateChain(
        base64Certificates: certificates
      )
      return chainVerifier.isChainTrustResultSuccesful(verified ?? .failure)
    }
    
    let keySet = try WebKeySet(jwk: rsaJWK)
    let wallet: SiopOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try .init(rawValue: "did:example:123"),
      privateKey: privateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .x509SanDns(trust: chainVerifier)
      ],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .default()
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
    let url = session["request_uri"]
    
    overrideDependencies()
    let result = await sdk.authorize(
      url: URL(
        string: "eudi-wallet://authorize?client_id=\(TestsConstants.clientId)&request_uri=\(url!)"
      )!
    )
    
    switch result {
    case .invalidResolution(let error, let details):
      let result: DispatchOutcome = try await sdk.dispatch(
        error: error,
        details: details
      )
      switch result {
      case .rejected:
        XCTAssert(true)
      default:
        XCTAssert(false)
      }
    default:
      break
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
    
    let ecPublicJwkString = try? XCTUnwrap(
      ecPublicJwk.toDictionary().toJSONString(),
      "Expected non-nil value"
    )
    
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
    
    let rsaPublicJwkString: String! = try? XCTUnwrap(
      rsaJWK.toDictionary().toJSONString(),
      "Expected non-nil value"
    )
    
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
      "subject_syntax_types_supported": ["urn:ietf:params:oauth:jwk-thumbprint", "did:example", "did:key"]
    }
    """
    
    let clientMetaData = try ClientMetaData(metaDataString: clientMetaDataString)
    
    let validator = ClientMetaDataValidator()
    
    guard let validatedClientMetaData = try? await validator.validate(
      clientMetaData: clientMetaData,
      responseMode: nil,
      responseEncryptionConfiguration: .unsupported
    ) else {
      XCTAssert(false, "Invalid client metadata")
      return
    }
    
    let resolved: ResolvedRequestData = .vpToken(
      request: .init(
        presentationQuery: .byDigitalCredentialsQuery(
          try! .init(credentials: [
            .init(
              id: .init(value: "query_0"),
              format: .init(format: "sd-jwt"),
              meta: [:]
            )
          ])
        ),
        clientMetaData: validatedClientMetaData,
        client: .preRegistered(
          clientId: "https%3A%2F%2Fclient.example.org%2Fcb",
          legalName: "Verifier"
        ),
        nonce: "0S6_WzA2Mj",
        responseMode: .directPostJWT(responseURI: URL(string: "https://respond.here")!),
        state: "state",
        vpFormatsSupported: try! VpFormatsSupported(from: TestsConstants.testVpFormatsSupportedTO())!,
        responseEncryptionSpecification: .init(
          responseEncryptionAlg: .init(.ECDH_ES),
          responseEncryptionEnc: .init(.A128GCM),
          clientKey: try! .init(jwks: [ecPublicJwk, rsaJWK])
        )
      )
    )
    
    // Obtain consent
    let consent: ClientConsent = .vpToken(
      vpContent: .dcql(verifiablePresentations: [
        try QueryId(value: "query_0"): [.generic(TestsConstants.cbor)]
      ])
    )
    
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
        privateKey: rsaPrivateKey!,
        publicWebKeySet: rsaKeySet,
        supportedClientIdSchemes: [],
        vpFormatsSupported: ClaimFormat.default(),
        vpConfiguration: .default(),
        responseEncryptionConfiguration: .default()
      )
    )
    
    let service = AuthorisationService()
    let dispatcher = Dispatcher(service: service, authorizationResponse: response)
    _ = try? await dispatcher.dispatch()
    
    let joseResponse = await service.joseResponse
    let encryptedJwe = try JWE(compactSerialization: joseResponse!)
    
    let decrypter = Decrypter(
      keyManagementAlgorithm: .ECDH_ES,
      contentEncryptionAlgorithm: .A128GCM,
      decryptionKey: ecPrivateJWK
    )!
    
    let decryptionPayload = try encryptedJwe.decrypt(using: decrypter)
    
    let jwt = String(
      data: decryptionPayload.data(),
      encoding: .utf8
    )
    
    XCTAssertTrue(true, jwt!)
  }
  
  func testSDKEndtoEndWebVerifierDirectPostJwtX509() async throws {
    
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
    
    let chainVerifier: CertificateTrust = { certificates in
      
      guard let leaf = certificates.first else {
        return false
      }
      
      let chainVerifier = X509CertificateChainVerifier()
      let verified = try? await chainVerifier.verifyChain(
        rootBase64Certificates: TestsConstants.loadRootCertificates(),
        intermediateBase64Certificates: Array(certificates.dropFirst()),
        leafBase64Certificate: leaf
      )
      return chainVerifier.isChainTrustResultSuccesful(verified ?? .failure)
    }
    
    let keySet = try WebKeySet(jwk: rsaJWK)
    let wallet: SiopOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try .init(rawValue: "did:example:123"),
      privateKey: privateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .x509SanDns(trust: chainVerifier)
      ],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .default()
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
    
    /// To get this URL, visit https://dev.verifier.eudiw.dev/
    /// and  "Request for the entire PID"
    /// Copy the "Authenticate with wallet link", choose the value for "request_uri"
    /// Decode the URL online and paste it below in the url variable
    /// Note:  The url is only valid for one use
    let url = "#09"
    
    overrideDependencies()
    let result = await sdk.authorize(
      url: URL(
        string: url
      )!
    )
    
    switch result {
    case .jwt(request: let request):
      // Obtain consent
      let consent: ClientConsent = .vpToken(
        vpContent: .dcql(verifiablePresentations: [
          try QueryId(value: "query_0"): [.generic(TestsConstants.cbor)]
        ])
      )
      
      // Generate a direct post authorisation response
      let response = try? XCTUnwrap(AuthorizationResponse(
        resolvedRequest: request,
        consent: consent,
        walletOpenId4VPConfig: wallet
      ), "Expected item to be non-nil")
      
      // Dispatch
      XCTAssertNotNil(response)
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      switch result {
      case .accepted:
        XCTAssert(true)
      default:
        XCTAssert(false)
      }
    default:
      XCTExpectFailure("This tests depends on a verifier url")
      XCTAssert(false)
    }
  }
  
  func testSDKEndtoEndWebVerifierDirectPostJwtX509DCQL() async throws {
    
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
    
    let chainVerifier = { certificates in
      let chainVerifier = X509CertificateChainVerifier()
      let verified = try? chainVerifier.verifyCertificateChain(
        base64Certificates: certificates
      )
      return chainVerifier.isChainTrustResultSuccesful(verified ?? .failure)
    }
    
    let keySet = try WebKeySet(jwk: rsaJWK)
    let wallet: SiopOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try .init(rawValue: "did:example:123"),
      privateKey: privateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .x509SanDns(trust: chainVerifier)
      ],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .default()
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
    
    /// To get this URL, visit https://dev.verifier.eudiw.dev/
    /// and  "Request for the entire PID"
    /// Copy the "Authenticate with wallet link", choose the value for "request_uri"
    /// Decode the URL online and paste it below in the url variable
    /// Note:  The url is only valid for one use
    let url = "#10"
    
    overrideDependencies()
    let result = await sdk.authorize(
      url: URL(
        string: url
      )!
    )
    
    switch result {
    case .jwt(let request):
      
      // Obtain consent
      let consent: ClientConsent = .vpToken(
        vpContent: .dcql(verifiablePresentations: [
          try QueryId(value: "query_0"): [.generic(TestsConstants.cbor)]
        ])
      )
      
      // Generate a direct post authorisation response
      let response = try? XCTUnwrap(AuthorizationResponse(
        resolvedRequest: request,
        consent: consent,
        walletOpenId4VPConfig: wallet
      ), "Expected item to be non-nil")
      
      // Dispatch
      XCTAssertNotNil(response)
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      switch result {
      case .accepted:
        XCTAssert(true)
      default:
        XCTAssert(false)
      }
    default:
      XCTExpectFailure("This tests depends on a verifier url")
      XCTAssert(false)
    }
  }
  
  func testSDKEndtoEndWebVerifierX509DirectPostJwt() async throws {
    
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
    
    let chainVerifier = { certificates in
      let chainVerifier = X509CertificateChainVerifier()
      let verified = try? chainVerifier.verifyCertificateChain(
        base64Certificates: certificates
      )
      return chainVerifier.isChainTrustResultSuccesful(verified ?? .failure)
    }
    
    let keySet = try WebKeySet(jwk: rsaJWK)
    let wallet: SiopOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try .init(rawValue: "did:example:123"),
      privateKey: privateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .x509SanDns(trust: chainVerifier)
      ],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .default()
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
    
    /// To get this URL, visit https://dev.verifier.eudiw.dev/
    /// and  "Request for the entire PID"
    /// Copy the "Authenticate with wallet link", choose the value for "request_uri"
    /// Decode the URL online and paste it below in the url variable
    /// Note:  The url is only valid for one use
    let url = "#09"
    
    overrideDependencies()
    let result = await sdk.authorize(
      url: URL(
        string: url
      )!
    )
    
    switch result {
    case .jwt(request: let request):
      // Obtain consent
      let consent: ClientConsent = .vpToken(
        vpContent: .dcql(verifiablePresentations: [
          try QueryId(value: "query_0"): [.generic(TestsConstants.cbor)]
        ])
      )
      
      // Generate a direct post authorisation response
      let response = try? XCTUnwrap(AuthorizationResponse(
        resolvedRequest: request,
        consent: consent,
        walletOpenId4VPConfig: wallet
      ), "Expected item to be non-nil")
      
      // Dispatch
      XCTAssertNotNil(response)
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      switch result {
      case .accepted:
        XCTAssert(true)
      default:
        XCTAssert(false)
      }
    default:
      XCTExpectFailure("This tests depends on a verifier url")
      XCTAssert(false)
    }
  }
}

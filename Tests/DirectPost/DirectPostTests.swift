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
import CryptoKit

import XCTest
import Mockingbird
import JOSESwift

@testable import SiopOpenID4VP

final class DirectPostTests: DiXCTest {
  
  func testValidDirectPostAuthorisationResponseGivenValidResolutionAndConsent() async throws {
    
    let validator = ClientMetaDataValidator()
    let metaData = try await validator.validate(clientMetaData: Constants.testClientMetaData())
    
    // Obtain an id token resolution
    let resolved: ResolvedRequestData = .idToken(
      request: .init(
        idTokenType: .attesterSigned,
        clientMetaData: metaData,
        client: Constants.testClient,
        nonce: TestsConstants.testNonce,
        responseMode: TestsConstants.testResponseMode,
        state: TestsConstants.generateRandomBase64String(),
        scope: TestsConstants.testScope
      )
    )
    
    // Generate a random JWT
    let jwt = TestsConstants.generateRandomJWT()
    
    // Obtain consent
    let consent: ClientConsent = .idToken(idToken: jwt)
    
    // Generate a direct post authorisation response
    let response = try? AuthorizationResponse(
      resolvedRequest: resolved,
      consent: consent,
      walletOpenId4VPConfig: nil
    )
    
    XCTAssertNotNil(response)
  }
  
  func testExpectedErrorGivenValidResolutionAndNegaticeConsent() async throws {
    
    let validator = ClientMetaDataValidator()
    let metaData = try await validator.validate(clientMetaData: Constants.testClientMetaData())
    
    // Obtain an id token resolution
    let resolved: ResolvedRequestData = .idToken(
      request: .init(
        idTokenType: .attesterSigned,
        clientMetaData: metaData,
        client: Constants.testClient,
        nonce: TestsConstants.testNonce,
        responseMode: TestsConstants.testResponseMode,
        state: TestsConstants.generateRandomBase64String(),
        scope: TestsConstants.testScope
      )
    )
    
    // Do not obtain consent
    let consent: ClientConsent = .negative(message: "user_cancelled")
    
    do {
      // Generate an error since consent was not given
      let response = try AuthorizationResponse(
        resolvedRequest: resolved,
        consent: consent,
        walletOpenId4VPConfig: nil
      )
      
      switch response {
      case .directPost(_, data: let data):
        switch data {
        case .noConsensusResponseData(state: let state, error: _):
          XCTAssert(true, state)
          return
        default: XCTAssert(false, "Incorrect response type")
        }
      default: XCTAssert(false, "Incorrect response type")
      }
    } catch ValidatedAuthorizationError.negativeConsent {
      XCTAssert(true)
      return
    } catch {
      print(error.localizedDescription)
      XCTAssert(false)
    }
    
    XCTAssert(false)
  }
  
  func testPostDirectPostAuthorisationResponseGivenValidResolutionAndConsent() async throws {
    
    let validator = ClientMetaDataValidator()
    let metaData = try await validator.validate(clientMetaData: Constants.testClientMetaData())
    
    // Obtain an id token resolution
    let resolved: ResolvedRequestData = .idToken(
      request: .init(
        idTokenType: .attesterSigned,
        clientMetaData: metaData,
        client: Constants.testClient,
        nonce: TestsConstants.testNonce,
        responseMode: TestsConstants.testResponseMode,
        state: TestsConstants.generateRandomBase64String(),
        scope: TestsConstants.testScope
      )
    )
    
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
      decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123"),
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
      walletOpenId4VPConfig: nil
    )
    
    XCTAssertNotNil(response)
    
    let service = mock(AuthorisationServiceType.self)
    let dispatcher = Dispatcher(service: service, authorizationResponse: response!)
    await given(service.formCheck(poster: any(), response: any())) ~> ("", true)
    let result: DispatchOutcome = try await dispatcher.dispatch()
    
    XCTAssertNotNil(result)
  }
  
  func testPostDirectPostAuthorisationResponseGivenValidResolutionAndNegativeConsent() async throws {
    
    let validator = ClientMetaDataValidator()
    let metaData = try await validator.validate(clientMetaData: Constants.testClientMetaData())
    
    // Obtain an id token resolution
    let resolved: ResolvedRequestData = .idToken(
      request: .init(
        idTokenType: .attesterSigned,
        clientMetaData: metaData,
        client: Constants.testClient,
        nonce: TestsConstants.testNonce,
        responseMode: TestsConstants.testResponseMode,
        state: TestsConstants.generateRandomBase64String(),
        scope: TestsConstants.testScope
      )
    )
    
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
        signingKeySet: WebKeySet(keys: []),
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
    
    // Generate a direct post authorisation response
    let response = try? AuthorizationResponse(
      resolvedRequest: resolved,
      consent: consent,
      walletOpenId4VPConfig: nil
    )
    
    XCTAssertNotNil(response)
    
    let service = mock(AuthorisationServiceType.self)
    let dispatcher = Dispatcher(service: service, authorizationResponse: response!)
    await given(service.formCheck(poster: any(), response: any())) ~> ("", true)
    let result: DispatchOutcome = try await dispatcher.dispatch()
    
    XCTAssertNotNil(result)
  }
  
  
  func testSDKEndtoEndDirectPostVpToken() async throws {
    
    let publicKeysURL = URL(string: "\(TestsConstants.host)/wallet/public-keys.json")!
    
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
      supportedClientIdSchemes: [
        .preregistered(clients: [
          "verifier-backend.eudiw.dev": .init(
            clientId: "verifier-backend.eudiw.dev",
            legalName: "Verifier",
            jarSigningAlg: .init(.RS256),
            jwkSetSource: .fetchByReference(url: publicKeysURL)
          )
        ])
      ],
      vpFormatsSupported: []
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
    /// To get this URL, visit https://verifier.eudiw.dev/
    /// and  "Request for the entire PID"
    /// Copy the "Authenticate with wallet link", choose the value for "request_uri"
    /// Decode the URL online and paste it below in the url variable
    /// Note:  The url is only valid for one use
    let url = "#06"
    let clientId = "verifier-backend.eudiw.dev"
    
    overrideDependencies()
    let result = try? await sdk.authorize(url: URL(string: "eudi-wallet://authorize?client_id=\(clientId)&request_uri=\(url)")!)
    
    guard let result = result else {
      XCTExpectFailure("this tests depends on a local verifier running")
      XCTAssert(false)
      return
    }
    
    switch result {
    case .notSecured: break
    case .jwt(request: let request):
      let presentationDefinition = try?  XCTUnwrap(
        request.presentationDefinition,
        "Unable to resolve presentation definition"
      )
      
      XCTAssertNotNil(presentationDefinition)
      
      // Obtain consent
      let consent: ClientConsent = .vpToken(
        vpToken: .init(
          apu: TestsConstants.generateMdocGeneratedNonce(),
          verifiablePresentations: [
            .msoMdoc(TestsConstants.pidCbor)
          ]),
        presentationSubmission: TestsConstants.presentationSubmission(presentationDefinition!)
      )
      
      // Generate a direct post authorisation response
      let response = try? XCTUnwrap(AuthorizationResponse(
        resolvedRequest: request,
        consent: consent,
        walletOpenId4VPConfig: wallet
      ), "Expected a non-nil item")
      
      // Dispatch
      XCTAssertNotNil(response)
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      switch result {
      case .accepted:
        XCTAssert(true)
      default:
        XCTAssert(false)
      }
    }
  }
  
  func testSDKEndtoEndDirectPost() async throws {
    
    let nonce = UUID().uuidString
    let session = try? await TestsHelpers.getDirectPostSession(nonce: nonce)
    
    guard let session = session else {
      XCTExpectFailure("this tests depends on a local verifier running")
      XCTAssert(false)
      return
    }
    
    let publicKeysURL = URL(string: "\(TestsConstants.host)/wallet/public-keys.json")!
    
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
      supportedClientIdSchemes: [
        .preregistered(clients: [
          "verifier-backend.eudiw.dev": .init(
            clientId: "verifier-backend.eudiw.dev",
            legalName: "Verifier",
            jarSigningAlg: .init(.RS256),
            jwkSetSource: .fetchByReference(url: publicKeysURL)
          )
        ])
      ],
      vpFormatsSupported: []
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
    let url = session["request_uri"]
    let clientId = session["client_id"]
    let presentationId = session["presentation_id"] as! String
    
    overrideDependencies()
    let result = try? await sdk.authorize(url: URL(string: "eudi-wallet://authorize?client_id=\(clientId!)&request_uri=\(url!)")!)
    
    guard let result = result else {
      XCTExpectFailure("this tests depends on a local verifier running")
      XCTAssert(false)
      return
    }
    
    switch result {
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
      
      let publicKeysURL = URL(string: "\(TestsConstants.host)/wallet/public-keys.json")!
      
      let wallet: WalletOpenId4VPConfiguration = .init(
        subjectSyntaxTypesSupported: [
          .decentralizedIdentifier,
          .jwkThumbprint
        ],
        preferredSubjectSyntaxType: .jwkThumbprint,
        decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123"),
        signingKey: try KeyController.generateRSAPrivateKey(),
        signingKeySet: WebKeySet(keys: []),
        supportedClientIdSchemes: [
          .preregistered(clients: [
            "verifier-backend.eudiw.dev": .init(
              clientId: "verifier-backend.eudiw.dev",
              legalName: "Verifier",
              jarSigningAlg: .init(.RS256),
              jwkSetSource: .fetchByReference(url: publicKeysURL)
            )
          ])
        ],
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
      
      let pollingResult = try await TestsHelpers.pollVerifier(presentationId: presentationId, nonce: nonce)
      
      switch pollingResult {
      case .success:
        XCTAssert(true)
      case .failure:
        XCTAssert(false)
      }
    }
  }
}

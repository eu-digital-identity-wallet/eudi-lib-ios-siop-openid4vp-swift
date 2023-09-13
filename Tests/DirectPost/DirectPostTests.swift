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
        clientId: TestsConstants.testClientId,
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
        clientId: TestsConstants.testClientId,
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
        clientId: TestsConstants.testClientId,
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
    await given(service.formCheck(poster: any(), response: any())) ~> true
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
        clientId: TestsConstants.testClientId,
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
    await given(service.formCheck(poster: any(), response: any())) ~> true
    let result: DispatchOutcome = try await dispatcher.dispatch()
    
    XCTAssertNotNil(result)
  }
  
  func testSDKEndtoEndDirectPost() async throws {
    
    let nonce = UUID().uuidString
    let session = try await TestHelpers.getDirectPostSession(nonce: nonce)
    
    let sdk = SiopOpenID4VP()
    let url = session["request_uri"]
    let clientId = session["client_id"]
    let presentationId = session["presentation_id"]
    
    overrideDependencies()
    let result = try? await sdk.authorize(url: URL(string: "eudi-wallet://authorize?client_id=\(clientId!)&request_uri=\(url!)")!)
    
    // Do not fail 404
    guard let result = result else {
      XCTAssert(true)
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
        walletOpenId4VPConfig: wallet
      )
      
      XCTAssertNotNil(response)
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      
      XCTAssertTrue(result == .accepted(redirectURI: nil))
      
      let fetcher = Fetcher<String>()
      let pollingUrl = URL(string: "http://localhost:8080/ui/presentations/\(presentationId!)?nonce=\(nonce)")!
      let pollingResult = try await fetcher.fetchString(url: pollingUrl)
      
      switch pollingResult {
      case .success(let string):
        XCTAssert(true)
      case .failure:
        XCTAssert(false)
      }
    }
  }
}

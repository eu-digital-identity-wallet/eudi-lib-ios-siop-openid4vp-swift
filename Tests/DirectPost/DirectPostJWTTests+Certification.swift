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

final class DirectPostJWTCertificationTests: DiXCTest {
  
  func testGivenOnlineCertifierHappyPathTestPlanThenExpectSuccess() async throws {
    
    /// To get this URL, visit https://demo.certification.openid.net/
    /// and run a happy flow no state test
    let url = ""
    let clientId = "demo.certification.openid.net"
    
    guard !url.isEmpty else {
      XCTExpectFailure("The tests need a url")
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
        .x509SanDns(trust: chainVerifier)
      ],
      vpFormatsSupported: []
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
 
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
      let resolved = request
      
      // Obtain consent
      let consent: ClientConsent = .vpToken(
        vpToken: TestsConstants.certCbor,
        presentationSubmission: .init(
          id: "psId",
          definitionID: "psId",
          descriptorMap: []
        )
      )
      
      // Generate a direct post authorisation response
      let response = try? XCTUnwrap(AuthorizationResponse(
        resolvedRequest: resolved,
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
    }
  }
  
  func testGivenOnlineCertifierHappyPathWithRedirectTestPlanThenExpectSuccess() async throws {
    
    /// To get this URL, visit https://demo.certification.openid.net/
    /// and run a happy flow no state test
    let url = ""
    let clientId = "demo.certification.openid.net"
    
    guard !url.isEmpty else {
      XCTExpectFailure("The tests need a url")
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
        .x509SanDns(trust: chainVerifier)
      ],
      vpFormatsSupported: []
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
 
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
      let resolved = request
      
      // Obtain consent
      let consent: ClientConsent = .vpToken(
        vpToken: TestsConstants.certCbor,
        presentationSubmission: .init(
          id: "psId",
          definitionID: "psId",
          descriptorMap: []
        )
      )
      
      // Generate a direct post authorisation response
      let response = try? XCTUnwrap(AuthorizationResponse(
        resolvedRequest: resolved,
        consent: consent,
        walletOpenId4VPConfig: wallet
      ), "Expected item to be non-nil")
      
      // Dispatch
      XCTAssertNotNil(response)
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      switch result {
      case .accepted(let redirectURI):
        XCTAssertNotNil(redirectURI!.absoluteString)
        XCTAssert(true, "Redirect uri \(redirectURI!.absoluteString)")
      default:
        XCTAssert(false)
      }
    }
  }
  
  func testGivenOnlineCertifierHappyPathTestPlanThenExpectFailure() async throws {
    
    /// To get this URL, visit https://demo.certification.openid.net/
    /// and run a happy flow no state test
    let url = ""
    let clientId = "demo.certification.openid.net"
    
    guard !url.isEmpty else {
      XCTExpectFailure("The tests need a url")
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
        .x509SanDns(trust: chainVerifier)
      ],
      vpFormatsSupported: []
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
 
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
      let resolved = request
      
      // Obtain consent
      let consent: ClientConsent = .vpToken(
        vpToken: TestsConstants.certCbor,
        presentationSubmission: .init(
          id: "psId",
          definitionID: "psId",
          descriptorMap: []
        )
      )
      
      // Generate a direct post authorisation response
      let response = try? XCTUnwrap(AuthorizationResponse(
        resolvedRequest: resolved,
        consent: consent,
        walletOpenId4VPConfig: wallet
      ), "Expected item to be non-nil")
      
      // Dispatch
      XCTAssertNotNil(response)
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      switch result {
      case .accepted:
        XCTAssert(false)
      default:
        XCTAssert(true)
      }
    }
  }
}

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

final class DirectPostJWTCertificationAndConformanceTests: DiXCTest {
  
  func testExampleGivenOnlineCertifierHappyPathTestPlanThenExpectSuccess() async throws {
    
    /// To get this URL,  visit https://demo.certification.openid.net/
    /// and run a happy flow no state test then proceed to assign the request uri to the variable below
    let url = "#01"
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
    let wallet: SiopOpenId4VPConfiguration = .init(
      privateKey: privateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .x509SanDns(trust: chainVerifier)
      ],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .supported(
        supportedAlgorithms: [.init(.ECDH_ES)],
        supportedMethods: [.init(.A256GCM)]
      )
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
    
    overrideDependencies()
    let result = await sdk.authorize(
      url: URL(
        string: "eudi-wallet://authorize?client_id=\(clientId)&request_uri=\(url)"
      )!
    )
    
    switch result {
    case .jwt(request: let request):
      let resolved = request
      
      var presentation: String?
      var nonce: String?
      switch resolved {
      case .vpToken(let request):
        
        nonce = request.nonce
        presentation = TestsConstants.sdJwtPresentations(
          transactiondata: request.transactionData,
          clientID: request.client.id.clientId,
          nonce: nonce!,
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
        XCTAssert(false)
      }
    default:
      XCTExpectFailure()
      XCTAssert(false)
    }
  }
  
  func testExampleGivenOnlineCertifierHappyPathWithRedirectTestPlanThenExpectSuccess() async throws {
    
    /// To get this URL, visit https://demo.certification.openid.net/
    /// and run a happy flow no state test
    /// then proceed to assign the request uri to the variable below
    let url = "#02"
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
    let wallet: SiopOpenId4VPConfiguration = .init(
      privateKey: privateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .x509SanDns(trust: chainVerifier)
      ],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .unsupported
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
    
    overrideDependencies()
    let result = await sdk.authorize(
      url: URL(
        string: "eudi-wallet://authorize?client_id=\(clientId)&request_uri=\(url)"
      )!
    )
    
    switch result {
    case .jwt(request: let request):
      let resolved = request
      
      var presentation: String?
      var nonce: String?
      switch resolved {
      case .vpToken(let request):
        
        nonce = request.nonce
        presentation = TestsConstants.sdJwtPresentations(
          transactiondata: request.transactionData,
          clientID: request.client.id.originalClientId,
          nonce: nonce!,
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
        XCTAssertNotNil(redirectURI!.absoluteString)
        XCTAssert(true, "Redirect uri \(redirectURI!.absoluteString)")
      default:
        XCTAssert(false)
      }
    default:
      XCTExpectFailure()
      XCTAssert(false)
    }
  }
  
  func testExampleGivenOnlineCertifierHappyPathTestPlanThenExpectFailure() async throws {
    
    /// To get this URL, visit https://demo.certification.openid.net/
    /// and run a happy flow no state test
    /// then proceed to assign the request uri to the variable below
    let url = "#03"
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
    let wallet: SiopOpenId4VPConfiguration = .init(
      privateKey: privateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .x509SanDns(trust: chainVerifier)
      ],
      vpFormatsSupported: ClaimFormat.default(),
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: .default(),
      responseEncryptionConfiguration: .unsupported
    )
    
    let sdk = SiopOpenID4VP(walletConfiguration: wallet)
    
    overrideDependencies()
    let result = await sdk.authorize(
      url: URL(
        string: "eudi-wallet://authorize?client_id=\(clientId)&request_uri=\(url)"
      )!
    )
    
    switch result {
    case .jwt(request: let request):
      let resolved = request
      
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
        XCTAssert(false)
      default:
        XCTAssert(true)
      }
    default:
      XCTExpectFailure()
      XCTAssert(false)
    }
  }
}

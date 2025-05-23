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
import X509

@testable import SiopOpenID4VP

final class X509CertificateTests: XCTestCase {
  
  override func setUpWithError() throws {
  }
  
  override func tearDownWithError() throws {
  }
  
  func testSecKeyCreationFromX509Certificate() throws {
    
    if let data = Data(base64Encoded: TestsConstants.x5cCertificate) {
      let derBytes = [UInt8](data)
      let certificate = try Certificate(derEncoded: derBytes)
      
      let publicKey = certificate.publicKey
      let pem = try publicKey.serializeAsPEM().pemString
      
      let secKey = KeyController.convertPEMToPublicKey(pem)
      XCTAssertNotNil(secKey)
      
      let clientIndentifier = "client_identifer.example.com"
      guard let dnss = try? certificate.extensions.subjectAlternativeNames?.rawSubjectAlternativeNames() else {
        XCTFail("Could not locate subject alternative names")
        return
      }
      XCTAssert(!dnss.isEmpty)
      XCTAssert(dnss.contains(where: { $0 == clientIndentifier }))
      
      let uri = "https://www.example.com"
      guard let uris = try? certificate.extensions.subjectAlternativeNames?.rawUniformResourceIdentifiers() else {
        XCTFail("Could not locate uri's")
        return
      }
      XCTAssert(!uris.isEmpty)
      XCTAssert(uris.contains(where: { $0 == uri }))
      
      let valid = publicKey.isValidSignature(certificate.signature, for: certificate)
      XCTAssert(valid)
      
      let legacyCertificate = SecCertificateCreateWithData(nil, data as CFData)
      XCTAssertNotNil(legacyCertificate)
      
    } else {
      XCTFail("Could not get SecKey from base64 x509")
    }
  }
  
  func testVerifyRawCerticateChain() {
    
    guard
      let rootCertData = Data(base64Encoded: TestsConstants.x5cRootCertificate),
      let leafCertData = Data(base64Encoded: TestsConstants.x5cLeafCertificate),
      let interCertData = Data(base64Encoded: TestsConstants.x5cInterCertificate)
    else {
      return
    }
    // Create a certificate object for the root certificate
    let rootCert = SecCertificateCreateWithData(nil, rootCertData as CFData)
    
    // Create a certificate object for the leaf certificate
    let leafCert = SecCertificateCreateWithData(nil, leafCertData as CFData)
    
    // Create a certificate object for the intermediate certificate
    let interCert = SecCertificateCreateWithData(nil, interCertData as CFData)
    
    // Create a certificate trust object
    var trust: SecTrust?
    let policy = SecPolicyCreateBasicX509()
    
    let certificates = [leafCert, interCert, rootCert] // Add intermediate certificates if needed
    
    // Set the certificate chain and policy for trust evaluation
    SecTrustCreateWithCertificates(certificates as CFTypeRef, policy, &trust)
    
    // Evaluate the trust
    var trustResult: SecTrustResultType = .invalid
    _ = SecTrustEvaluate(trust!, &trustResult)
    
    // Check if the trust evaluation was successful
    if trustResult == .unspecified || trustResult == .proceed || trustResult == .recoverableTrustFailure {
      XCTAssert(true)
    } else {
        
      XCTAssert(false)
    }
  }
  
  func testVerifyCerticateChainWithVerifier() {
    
    let chainVerifier = X509CertificateChainVerifier()
    
    do {
      let verified = try chainVerifier.verifyCertificateChain(
        base64Certificates: [
          TestsConstants.x5cRootCertificateBase64,
          TestsConstants.x5cInterCertificateBase64,
          TestsConstants.x5cLeafCertificateBase64
        ]
      )

      XCTAssert(chainVerifier.isChainTrustResultSuccesful(verified))
      
    } catch {
      XCTAssert(false, "Unable to verify certificate chain")
    }
  }
  
  func testRawCertificateRevokation() {
    
    guard
      let rootCertData = Data(base64Encoded: TestsConstants.x5cRootCertificate)
    else {
      return
    }
    // Create a certificate object for the root certificate
    let certificate = SecCertificateCreateWithData(nil, rootCertData as CFData)
    
    if let certificate = certificate {
      
      // Create a policy for certificate validation
      let policy = SecPolicyCreateBasicX509()
      
      // Create a trust object with the certificate and policy
      var trust: SecTrust?
      if SecTrustCreateWithCertificates(certificate, policy, &trust) == errSecSuccess {
        
        // Set the OCSP responder URL
        let ocspResponderURL = URL(string: "http://ocsp.example.com")!
        SecTrustSetNetworkFetchAllowed(trust!, true)
        SecTrustSetOCSPResponse(trust!, ocspResponderURL as CFURL)
        
        // Evaluate the trust
        var trustResult: SecTrustResultType = .invalid
        if SecTrustEvaluate(trust!, &trustResult) == errSecSuccess {
          if trustResult == .proceed || trustResult == .unspecified {
            print("Certificate is not revoked.")
          } else if trustResult == .deny || trustResult == .fatalTrustFailure {
            print("Certificate is revoked.")
          } else {
            print("Certificate status is unknown.")
          }
        } else {
          print("Failed to evaluate the certificate trust.")
        }
      } else {
        print("Failed to create trust object.")
      }
    }
  }
  
  func testCertificateRevokationWithVerifier() {
    
    let chainVerifier = X509CertificateChainVerifier()
    
    do {
      let notRevoked = try chainVerifier.checkCertificateValidAndNotRevoked(base64Certificate: TestsConstants.x5cRootCertificateBase64)
      XCTAssert(notRevoked)
      
    } catch {
      XCTAssert(false, "Unable to verify certificate chain")
    }
  }
  
  func testVerifyCerticateChainWithX509Verifier() async throws {
    
    let chainVerifier = X509CertificateChainVerifier()
    let certs = TestsConstants.x509CertificateChain
    let verified = try! await chainVerifier.verifyChain(
      rootBase64Certificates: [certs.last!],
      intermediateBase64Certificates: [certs[1]],
      leafBase64Certificate: certs.first!
    )
    
    if case .success = verified {
      XCTAssertTrue(true)
    } else {
      XCTFail("Expected .validCertificate, got \(verified)")
    }
  }
  
  func testVerifyVerifierCerticateChainWithX509Verifier() async throws {
    
    let chainVerifier = X509CertificateChainVerifier()
    let verified = try! await chainVerifier.verifyChain(
      rootBase64Certificates: TestsConstants.loadRootCertificates(),
      intermediateBase64Certificates: [],
      leafBase64Certificate: TestsConstants.verifierCertificate
    )
    
    if case .success = verified {
      XCTAssertTrue(true)
    } else {
      XCTFail("Expected .validCertificate, got \(verified)")
    }
  }
}

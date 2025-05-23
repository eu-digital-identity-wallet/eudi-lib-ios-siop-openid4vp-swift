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
import X509
import Security

public enum ChainTrustResult: Equatable {
  case success
  case recoverableFailure(String)
  case failure
}

enum CertificateValidationError: Error {
  case invalidCertificateData
  case insufficientCertificates
  case signatureValidationFailed
  case certificateExpired
  case untrustedRoot
}

public enum DataConversionError: Error {
  case conversionFailed(String)
}

public struct X509CertificateChainVerifier {
  
  public init() {
    
  }
  
  public func isChainTrustResultSuccesful(_ result: ChainTrustResult) -> Bool {
    return result != .failure
  }
  
  public func verifyCertificateChain(base64Certificates: [Base64Certificate]) throws -> ChainTrustResult {
    
    let certificates = try convertStringsToData(
      base64Strings: base64Certificates
    ).compactMap {
      SecCertificateCreateWithData(nil, $0 as CFData)
    }.compactMap {
      SecCertificateContainer(certificate: $0)
    }
    
    if certificates.isEmpty {
      return .failure
    }
    
    switch SecCertificateHelper.validateCertificateChain(
      certificates: certificates
    ) {
    case .invalid, .deny, .fatalTrustFailure, .otherError:
      return .failure
    case .proceed, .unspecified:
      return .success
    case .recoverableTrustFailure:
      return .recoverableFailure("Recoverable failure")
    @unknown default:
      return .failure
    }
  }
  
  public func checkCertificateValidAndNotRevoked(base64Certificate: Base64Certificate) throws -> Bool{
    
    let certificates = try convertStringsToData(
      base64Strings: [base64Certificate]
    ).compactMap {
      SecCertificateCreateWithData(nil, $0 as CFData)
    }
    
    guard
      certificates.count == 1
    else {
      return false
    }
    
    if let certificate = certificates.first {
      
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
          if trustResult == .proceed || trustResult == .unspecified || trustResult == .recoverableTrustFailure {
            return true
          } else if trustResult == .deny || trustResult == .fatalTrustFailure {
            return false
          } else {
            return false
          }
        } else {
          return false
        }
      } else {
        return false
      }
      
    } else {
      return false
    }
  }
  
  public func areCertificatesLinked(
    rootCertificateBase64: String,
    otherCertificateBase64: String
  ) -> Bool {
    guard
      let rootCertificateData = Data(base64Encoded: rootCertificateBase64),
      let otherCertificateData = Data(base64Encoded: otherCertificateBase64)
    else {
      return false // Invalid Base64-encoded data
    }
    
    // Create SecCertificate objects from DER data
    if let rootCertificate = SecCertificateCreateWithData(nil, rootCertificateData as CFData),
       let otherCertificate = SecCertificateCreateWithData(nil, otherCertificateData as CFData) {
      
      // Create a trust object and evaluate it
      var trust: SecTrust?
      var policy: SecPolicy?
      
      policy = SecPolicyCreateBasicX509()
      let policies = [policy!] as CFArray
      
      let status = SecTrustCreateWithCertificates([rootCertificate] as CFArray, policies, &trust)
      
      if status == errSecSuccess {
        SecTrustSetAnchorCertificates(trust!, [rootCertificate] as CFArray)
        
        let otherCertificates = [otherCertificate] as CFArray
        SecTrustSetAnchorCertificatesOnly(trust!, true)
        SecTrustSetAnchorCertificates(trust!, otherCertificates)
        
        var trustResult: SecTrustResultType = .invalid
        SecTrustEvaluate(trust!, &trustResult)
        
        return trustResult == .unspecified || trustResult == .proceed
      }
    }
    
    return false // The certificates are not linked
  }
}

private extension X509CertificateChainVerifier {
  
  func convertStringsToData(base64Strings: [String]) throws -> [Data] {
    base64Strings.compactMap { base64String in
      if let data = Data(base64Encoded: base64String),
         let string = String(
          data: data,
          encoding: .utf8
         )?.removeCertificateDelimiters(),
         let finalData = Data(base64Encoded: string) {
        return finalData
      }
      return Data(base64Encoded: base64String)
    }
  }
}

public extension X509CertificateChainVerifier {
  
  /// Validates that each certificate is signed by the next in the chain and that the leaf is valid at the current time
  func validateChainSwiftCertificates(base64Certificates: [Base64Certificate]) throws -> Bool {
    
    /// Converts a `SecCertificate` to `X509.Certificate`
    func convertToX509Certificate(_ secCert: SecCertificate) throws -> Certificate {
      let derData = SecCertificateCopyData(secCert) as Data
      return try Certificate(derEncoded: [UInt8](derData))
    }
    
    let certificates = try convertStringsToData(
      base64Strings: base64Certificates
    ).compactMap {
      SecCertificateCreateWithData(nil, $0 as CFData)
    }.compactMap {
      SecCertificateContainer(certificate: $0)
    }
    
    if certificates.isEmpty {
      return false
    }
    
    let x509Certs: [Certificate] = try certificates.compactMap {
      guard let cert = $0.certificate else { return nil }
      return try convertToX509Certificate(cert)
    }
    
    guard x509Certs.count >= 2 else {
      throw CertificateValidationError.insufficientCertificates
    }
    
    // Leaf is first, root is last
    let leaf = x509Certs.first!
    
    // Check validity period for leaf
    let now = Date()
    guard leaf.notValidBefore <= now,
          leaf.notValidAfter >= now
    else {
      throw CertificateValidationError.certificateExpired
    }
    
    // Check each cert is signed by the next one (issuer signs subject)
    for (current, issuer) in zip(x509Certs, x509Certs.dropFirst()) {
      guard issuer.publicKey.isValidSignature(
        current.signature,
        for: current
      ) else {
        throw CertificateValidationError.signatureValidationFailed
      }
    }
    
    return true
  }
}

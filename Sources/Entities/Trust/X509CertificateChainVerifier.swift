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
  case invalidChain([VerificationResult.PolicyFailure])
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
  
  /// Converts a `SecCertificate` to `X509.Certificate`
  private func convertToX509Certificate(_ secCert: SecCertificate) throws -> Certificate {
    let derData = SecCertificateCopyData(secCert) as Data
    return try Certificate(derEncoded: [UInt8](derData))
  }
  
  func verifyChain(
    rootBase64Certificates: [Base64Certificate],
    intermediateBase64Certificates: [Base64Certificate] = [],
    leafBase64Certificate: Base64Certificate,
    date: Date = Date(),
    showDiagnostics: Bool = false
  ) async throws -> ChainTrustResult {
    
    func decodeBase64Certificates(
      _ base64s: [Base64Certificate]
    ) throws -> [Certificate] {
      return try convertStringsToData(base64Strings: base64s)
        .compactMap { SecCertificateCreateWithData(nil, $0 as CFData) }
        .compactMap { SecCertificateContainer(certificate: $0).certificate }
        .map { try convertToX509Certificate($0) }
    }
    
    let rootX509Certs = try decodeBase64Certificates(rootBase64Certificates)
    let intermediateX509Certs = try decodeBase64Certificates(intermediateBase64Certificates)
    let leafX509Certs = try decodeBase64Certificates([leafBase64Certificate])
    
    guard let leafCert = leafX509Certs.first else {
      throw CertificateValidationError.insufficientCertificates
    }
    
    let roots = CertificateStore(rootX509Certs)
    var verifier = Verifier(
      rootCertificates: roots
    ) {
        AnyPolicy {
          RFC5280Policy(validationTime: date)
      }
    }
    
    let result = await verifier.validate(
      leafCertificate: leafCert,
      intermediates: .init(
        intermediateX509Certs
      )
    ) { diagnostic in
      if showDiagnostics {
        print(diagnostic.multilineDescription)
      }
    }
    
    switch result {
    case .validCertificate:
      return .success
    case .couldNotValidate(let policyFailures):
      throw CertificateValidationError.invalidChain(
        policyFailures
      )
    }
  }
}

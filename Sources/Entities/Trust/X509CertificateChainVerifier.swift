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

public enum DataConversionError: Error {
  case conversionFailed(String)
}

public struct X509CertificateChainVerifier {
  
  public func isChainTrustResultSuccesful(_ result: ChainTrustResult) -> Bool {
    return result != .failure
  }
  
  public func verifyCertificateChain(base64Certificates: [Base64Certificate]) throws -> ChainTrustResult {
    
    let certificates = try convertStringsToData(
      base64Strings: base64Certificates
    ).compactMap { 
      SecCertificateCreateWithData(nil, $0 as CFData)
    }
    
    if certificates.isEmpty {
      return .failure
    }
    
    // Create a certificate trust object
    var trust: SecTrust?
    let policy = SecPolicyCreateBasicX509()
    
    // Set the certificate chain and policy for trust evaluation
    SecTrustCreateWithCertificates(certificates as CFTypeRef, policy, &trust)
    
    // Evaluate the trust
    var trustResult: SecTrustResultType = .invalid
    _ = SecTrustEvaluate(trust!, &trustResult)
    
    // Check if the trust evaluation was successful
    if trustResult == .unspecified {
      return .success
      
    } else if trustResult == .recoverableTrustFailure {
      var error: CFError?
      _ = SecTrustEvaluateWithError(trust!, &error)
      return .recoverableFailure(error?.localizedDescription ?? "Unknown .recoverableFailure")
               
     } else {
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
          if trustResult == .proceed || trustResult == .unspecified {
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
}

private extension X509CertificateChainVerifier {
  
  func convertStringsToData(base64Strings: [String]) throws -> [Data] {
    var dataObjects: [Data] = []
    for base64String in base64Strings {
      if let data = Data(base64Encoded: base64String),
         let string = String(data: data, encoding: .utf8)?.removeCertificateDelimiters(),
         let encodedData = Data(base64Encoded: string) {
        dataObjects.append(encodedData)
      } else {
        throw DataConversionError.conversionFailed("Failed to convert base64 string: \(base64String)")
      }
    }
    
    return dataObjects
  }
}

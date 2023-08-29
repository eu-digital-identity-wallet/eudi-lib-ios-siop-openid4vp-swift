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
import Security

public class KeyController {
  
  static func generateHardcodedRSAPrivateKey() throws -> SecKey? {
    
    // Convert PEM key to Data
    guard
      let contents = String.loadStringFileFromBundle(
        named: "sample_derfile",
        withExtension: "der"
      )?.replacingOccurrences(of: "\n", with: ""),
      let data = Data(base64Encoded: contents)
    else {
      return nil
    }
    
    // Define the key attributes
    let attributes: [CFString: Any] = [
      kSecAttrKeyType: kSecAttrKeyTypeRSA,
      kSecAttrKeyClass: kSecAttrKeyClassPrivate
    ]
    
    // Create the SecKey object
    var error: Unmanaged<CFError>?
    guard let secKey = SecKeyCreateWithData(data as CFData, attributes as CFDictionary, &error) else {
      if let error = error?.takeRetainedValue() {
        print("Failed to create SecKey:", error)
      }
      return nil
    }
    return secKey
  }
  
  static func generateRSAPrivateKey() throws -> SecKey {
    let attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
      kSecAttrKeySizeInBits as String: 2048
    ]
    
    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
      throw error!.takeRetainedValue() as Error
    }
    return privateKey
  }
  
  static func generateRSAPublicKey(from privateKey: SecKey) throws -> SecKey {
    guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
      throw JOSEError.invalidPublicKey
    }
    return publicKey
  }
  
  static func generateECDHPrivateKey() throws -> SecKey {
    let attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrKeySizeInBits as String: 256
    ]
    
    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
      throw error!.takeRetainedValue() as Error
    }
    return privateKey
  }
  
  static func generateECDHPublicKey(from privateKey: SecKey) throws -> SecKey {
    guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
      throw NSError(domain: "YourDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate public key"])
    }
    return publicKey
  }
  
  static func convertRSAPrivateKeyToPEM(key: SecKey) throws -> String {
    
    // Convert to DER first
    var error: Unmanaged<CFError>?
    guard let derData = SecKeyCopyExternalRepresentation(key, &error) as Data? else {
      throw error?.takeRetainedValue() as Error? ?? NSError(domain: "SecKeyError", code: -1, userInfo: nil)
    }
    
    let base64Encoded = derData.base64EncodedString()
    var pemString = "-----BEGIN RSA PRIVATE KEY-----\n"
    pemString += base64Encoded.chunked(length: 64)
      .joined(separator: "\n")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "=", with: "")
    pemString += "\n-----END RSA PRIVATE KEY-----\n"
    return pemString
  }
}

private extension String {
  func chunked(length: Int) -> [String] {
    var index = startIndex
    var chunks = [String]()
    while index < endIndex {
      let endIndex = self.index(index, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
      let chunk = self[index..<endIndex]
      chunks.append(String(chunk))
      index = endIndex
    }
    return chunks
  }
}

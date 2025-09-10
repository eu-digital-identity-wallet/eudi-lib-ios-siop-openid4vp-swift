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

extension Data {
  // Generates random data of the specified length
  static func randomData(length: Int) -> Data {
    var data = Data(count: length)
    _ = data.withUnsafeMutableBytes { mutableBytes in
      if let bytes = mutableBytes.bindMemory(to: UInt8.self).baseAddress {
        return SecRandomCopyBytes(kSecRandomDefault, length, bytes)
      }
      fatalError("Failed to generate random bytes")
    }
    return data
  }
  
  init?(base64UrlEncoded base64Url: String) {
    var base64 = base64Url
      .replacingOccurrences(of: "-", with: "+") // Replace '-' with '+'
      .replacingOccurrences(of: "_", with: "/") // Replace '_' with '/'
    
    // Pad with '=' to make the base64 string length a multiple of 4
    let paddingLength = 4 - base64.count % 4
    if paddingLength < 4 {
      base64.append(String(repeating: "=", count: paddingLength))
    }
    
    guard let data = Data(base64Encoded: base64) else { return nil }
    self = data
  }
  
  var base64URLEncodedString: String {
    return self.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}

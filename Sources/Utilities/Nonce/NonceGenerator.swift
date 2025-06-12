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

/// A utility struct for generating secure random nonces for use in cryptographic and unique identifier contexts.
public struct NonceGenerator {

  /// Generates a nonce of the specified length using alphanumeric characters.
  ///
  /// This method creates a nonce using a character set consisting of lowercase letters,
  /// uppercase letters, and numbers. It is suitable for nonces that need to be URL-safe and human-readable.
  ///
  /// - Parameter length: The length of the nonce to be generated. Defaults to 32 characters.
  /// - Returns: A random alphanumeric string of the specified length.
  /// - Throws: `NonceError.invalidLength` if the provided length is less than or equal to zero.
  public static func generate(length: Int = 32) throws -> String {
    guard length > 0 else {
      throw NonceError.invalidLength
    }

    let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var nonce = ""

    for _ in 0..<length {
      guard let randomCharacter = characters.randomElement() else { continue }
      nonce.append(randomCharacter)
    }

    return nonce
  }

  /// Generates a cryptographically secure nonce as a base64-encoded string.
  ///
  /// This method uses the `CryptoKit` library to generate a nonce with random bytes, providing
  /// higher security than an alphanumeric string. The output nonce is base64-encoded for easy storage and transmission.
  ///
  /// - Parameter byteLength: The number of random bytes to use for generating the nonce. Defaults to 32 bytes.
  /// - Returns: A base64-encoded string representing the secure random nonce.
  public static func generateSecureNonce(byteLength: Int = 32) -> String {
    var randomBytes = [UInt8](repeating: 0, count: byteLength)
    _ = SecRandomCopyBytes(kSecRandomDefault, byteLength, &randomBytes)  // Using CryptoKit's secure random generator
    return Data(randomBytes).base64EncodedString()
  }
}

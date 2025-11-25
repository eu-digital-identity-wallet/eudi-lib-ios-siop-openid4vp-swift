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
import Foundation

@testable import OpenID4VP

final class NonceGeneratorTests: XCTestCase {

  func testGenerateNonceWhenLengthIsZero() {
    XCTAssertThrowsError(try NonceGenerator.generate(length: 0)) { error in
      XCTAssertEqual(error as? NonceError, .invalidLength)
    }
  }

  func testGenerateDefaultLength() throws {
    let nonce = try NonceGenerator.generate()
    XCTAssertEqual(nonce.count, 32)
  }

  func testGenerateCustomLength() throws {
    let nonce = try NonceGenerator.generate(length: 12)
    XCTAssertEqual(nonce.count, 12)
  }

  func testGenerateContainsOnlyAlphanumericCharacters() throws {
    let nonce = try NonceGenerator.generate(length: 100)
    let allowedChars = CharacterSet.alphanumerics
    XCTAssertTrue(nonce.unicodeScalars.allSatisfy { allowedChars.contains($0) })
  }

  func testGenerateRandomness() throws {
    let nonce1 = try NonceGenerator.generate()
    let nonce2 = try NonceGenerator.generate()
    XCTAssertNotEqual(nonce1, nonce2)
  }

  func testGenerateSecureNonceDefaultByteLength() {
    let secureNonce = NonceGenerator.generateSecureNonce()
    let data = Data(base64Encoded: secureNonce)
    XCTAssertNotNil(data)
    XCTAssertEqual(data?.count, 32)
  }

  func testGenerateSecureNonceCustomByteLength() {
    let secureNonce = NonceGenerator.generateSecureNonce(byteLength: 64)
    let data = Data(base64Encoded: secureNonce)
    XCTAssertNotNil(data)
    XCTAssertEqual(data?.count, 64)
  }

  func testGenerateSecureNonceRandomness() {
    let nonce1 = NonceGenerator.generateSecureNonce()
    let nonce2 = NonceGenerator.generateSecureNonce()
    XCTAssertNotEqual(nonce1, nonce2)
  }
}

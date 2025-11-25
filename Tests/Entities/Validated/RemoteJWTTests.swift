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
@testable import OpenID4VP

class RemoteJWTTests: XCTestCase {

  func testInitialiseRemoteJWT() {
    let jwtString = ("\(TestsConstants.header).\(TestsConstants.payload).\(TestsConstants.signature)")

    let remoteJWT = RemoteJWT(jwt: jwtString)

    XCTAssertEqual(remoteJWT.jwt, jwtString)
  }

  func testEncodeRemoteJWT() throws {
    let jwtString = ("\(TestsConstants.header).\(TestsConstants.payload).\(TestsConstants.signature)")
    let remoteJWT = RemoteJWT(jwt: jwtString)

    let encoder = JSONEncoder()
    let data = try encoder.encode(remoteJWT)

    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    XCTAssertEqual(json?["jwt"] as? String, jwtString)
  }

  func testDecodeRemoteJWT() throws {
    let jwtString = ("\(TestsConstants.header).\(TestsConstants.payload).\(TestsConstants.signature)")
    let json = """
        { "jwt": "\(jwtString)" }
        """.data(using: .utf8)!

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(RemoteJWT.self, from: json)

    XCTAssertEqual(decoded.jwt, jwtString)
  }
}

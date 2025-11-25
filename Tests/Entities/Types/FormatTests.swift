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

final class FormatTests: XCTestCase {
  func testInitWithValidFormat() throws {
    let format = try Format(format: "validFormat")
    XCTAssertEqual(format.format, "validFormat")
  }

  func testInitWithBlankFormat() {
    XCTAssertThrowsError(try Format(format: "")) { error in
      XCTAssertEqual(error as? FormatError, FormatError.blankValue)
    }

    XCTAssertThrowsError(try Format(format: "    ")) { error in
      XCTAssertEqual(error as? FormatError, FormatError.blankValue)
    }
  }

  func testEncodingAndDecoding() throws {
    let original = try Format(format: "jsonFormat")
    let encoder = JSONEncoder()
    let data = try encoder.encode(original)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(Format.self, from: data)

    XCTAssertEqual(decoded, original)
  }

  func testDecodingInvalidFormat() {
    let json = "\"   \"".data(using: .utf8)!
    let decoder = JSONDecoder()

    XCTAssertThrowsError(try decoder.decode(Format.self, from: json)) { error in
      XCTAssertEqual(error as? FormatError, FormatError.blankValue)
    }
  }

  func testDescription() throws {
    let format = try Format(format: "descFormat")
    XCTAssertEqual(format.description, "descFormat")
  }

  func testStaticMsoMdoc() throws {
    let format = try Format.MsoMdoc()
    XCTAssertEqual(format.format, OpenId4VPSpec.FORMAT_MSO_MDOC)
  }

  func testStaticSdJwtVc() throws {
    let format = try Format.SdJwtVc()
    XCTAssertEqual(format.format, OpenId4VPSpec.FORMAT_SD_JWT_VC)
  }

  func testStaticW3CJwtVcJSON() throws {
    let format = try Format.W3CJwtVcJson()
    XCTAssertEqual(format.format, OpenId4VPSpec.FORMAT_W3C_SIGNED_JWT)
  }
}

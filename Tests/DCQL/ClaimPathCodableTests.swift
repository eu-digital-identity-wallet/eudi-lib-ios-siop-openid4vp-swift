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

import Foundation
import SwiftyJSON

class ClaimPathCodableTests: XCTestCase {

  func testEncodeClaimPath() throws {
    let claimPath = ClaimPath([
      .claim(name: "user"),
      .arrayElement(index: 0),
      .claim(name: "email"),
      .allArrayElements
    ])

    let encodedData = try JSONEncoder().encode(claimPath)
    let jsonString = String(data: encodedData, encoding: .utf8)

    // Should encode to JSON like: ["user", 0, "email", null]
    XCTAssertEqual(jsonString, #"["user",0,"email",null]"#)
  }

  func testDecodeClaimPath() throws {
    let jsonString = #"["user",0,"email",null]"#
    let jsonData = jsonString.data(using: .utf8)!

    let decoded = try JSONDecoder().decode(ClaimPath.self, from: jsonData)

    let expected = ClaimPath([
      .claim(name: "user"),
      .arrayElement(index: 0),
      .claim(name: "email"),
      .allArrayElements
    ])

    XCTAssertEqual(decoded, expected)
  }

  func testRoundTripEncodeDecode() throws {
    let original = ClaimPath([
      .claim(name: "document"),
      .arrayElement(index: 3),
      .allArrayElements,
      .claim(name: "type")
    ])

    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(ClaimPath.self, from: data)

    XCTAssertEqual(decoded, original)
  }

  func testAppendClaimPathElement() {

    let initialPath = ClaimPath([
      .claim(name: "user"),
      .arrayElement(index: 0)
    ])

    let newElement = ClaimPathElement.claim(name: "email")

    let result = initialPath + newElement

    let expectedPath = ClaimPath([
      .claim(name: "user"),
      .arrayElement(index: 0),
      .claim(name: "email")
    ])

    XCTAssertEqual(result, expectedPath)
  }

  func testMergeClaimPaths() {
    let claimPath1 = ClaimPath([
      .claim(name: "user"),
      .arrayElement(index: 0),
      .claim(name: "email"),
      .arrayElement(index: 1)
    ])

    let claimPath2 = ClaimPath([
      .claim(name: "phone"),
      .arrayElement(index: 0),
      .claim(name: "address"),
      .arrayElement(index: 1)
    ])

    let expected = ClaimPath(claimPath1.value + claimPath2.value)

    let result = claimPath1 + claimPath2

    XCTAssertEqual(result, expected)
  }

  func testContainsPath() {
    let path = ClaimPath([
      .claim(name: "user"),
      .arrayElement(index: 0),
      .claim(name: "email")
    ])

    let subpath = ClaimPath([
      .claim(name: "user"),
      .arrayElement(index: 0)
    ])

    XCTAssertTrue(path.contains(subpath))
  }

  func testContainsOtherPathIsLonger() {
    let path = ClaimPath([
      .claim(name: "user")
    ])

    let longerPath = ClaimPath([
      .claim(name: "user"),
      .arrayElement(index: 0)
    ])

    XCTAssertFalse(path.contains(longerPath))
  }

  func testAllArrayElements() {
    let originalPath = ClaimPath([
      .claim(name: "user"),
      .arrayElement(index: 0)
    ])

    let result = originalPath.allArrayElements()

    let expected = ClaimPath([
      .claim(name: "user"),
      .arrayElement(index: 0),
      .allArrayElements
    ])

    XCTAssertEqual(result, expected)
  }

  func testArrayElement() {
    let originalPath = ClaimPath([
      .claim(name: "user")
    ])

    let result = originalPath.arrayElement(2)

    let expected = ClaimPath([
      .claim(name: "user"),
      .arrayElement(index: 2)
    ])

    XCTAssertEqual(result, expected)
  }

  func testClaimWhenClaimPathCalled() {
    let originalPath = ClaimPath([
      .arrayElement(index: 2)
    ])

    let result = originalPath.claim("email")

    let expected = ClaimPath([
      .arrayElement(index: 2),
      .claim(name: "email")
    ])

    XCTAssertEqual(result, expected)
  }

  func testParent() {
    let path = ClaimPath([
      .claim(name: "user"),
      .arrayElement(index: 0),
      .claim(name: "email")
    ])

    let expectedParent = ClaimPath([
      .claim(name: "user"),
      .arrayElement(index: 0)
    ])

    XCTAssertEqual(path.parent(), expectedParent)
  }

  func testParentOnlyOneElement() {
    let path = ClaimPath([
      .claim(name: "user")
    ])

    XCTAssertNil(path.parent())
  }

  func testParentEmptyPath() {
    let path = ClaimPath([])

    XCTAssertNil(path.parent())
  }

  func testHead() {
    let path = ClaimPath([
      .claim(name: "user"),
      .arrayElement(index: 0)
    ])

    XCTAssertEqual(path.head(), .claim(name: "user"))
  }

  func testTail() {
    let path = ClaimPath([
      .claim(name: "user"),
      .arrayElement(index: 0),
      .claim(name: "email")
    ])

    let expectedTail = ClaimPath([
      .arrayElement(index: 0),
      .claim(name: "email")
    ])

    XCTAssertEqual(path.tail(), expectedTail)
  }

  func testTailOnlyOneElement() {
    let path = ClaimPath([
      .claim(name: "user")
    ])

    XCTAssertNil(path.tail())
  }

  func testComponent1() {
    let path = ClaimPath([
      .claim(name: "user"),
      .arrayElement(index: 0)
    ])

    XCTAssertEqual(path.component1(), .claim(name: "user"))
  }

  func testComponent2() {
    let path = ClaimPath([
      .claim(name: "user"),
      .arrayElement(index: 0)
    ])

    let expectedTail = ClaimPath([
      .arrayElement(index: 0)
    ])

    XCTAssertEqual(path.component2(), expectedTail)
  }

  func testStaticClaim() {
    let result = ClaimPath.claim("email")
    let expected = ClaimPath([.claim(name: "email")])

    XCTAssertEqual(result, expected)
  }
}

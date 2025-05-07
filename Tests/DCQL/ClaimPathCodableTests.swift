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
@testable import SiopOpenID4VP

import XCTest
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
}


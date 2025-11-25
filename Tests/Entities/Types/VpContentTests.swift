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
import SwiftyJSON
@testable import OpenID4VP

class VpContentTests: XCTestCase {

  func testEncodeDCQLQueryWithGenericPresentation() throws {
    let queryId = try QueryId(value: "query1")
    let presentation: VerifiablePresentation = .generic("123")

    let result = VpContent.encodeDCQLQuery([queryId: [presentation]])

    XCTAssertEqual(result["query1"]?.arrayValue.first, "123")
  }

  func testEncodeDCQLQueryWithJsonPresentation() throws {

    let queryId = try QueryId(value: "query2")
    let json = JSON(["id": "456", "type": "JsonTest"])
    let presentation: VerifiablePresentation = .json(json)

    let result = VpContent.encodeDCQLQuery([queryId: [presentation]])

    XCTAssertEqual(result["query2"]?.array?.first?["id"].stringValue, "456")
    XCTAssertEqual(result["query2"]?.array?.first?["type"].stringValue, "JsonTest")
  }

  func testEncodeDCQLQueryWithMultiplePresentations() throws {
    let query1 = try QueryId(value: "q1")
    let query2 = try QueryId(value: "q2")

    let presentation1: VerifiablePresentation = .generic("John")
    let presentation2: VerifiablePresentation = .json(JSON(["age": "13"]))

    let query: [QueryId: [VerifiablePresentation]] = [
      query1: [presentation1],
      query2: [presentation2]
    ]

    let result = VpContent.encodeDCQLQuery(query)

    XCTAssertEqual(result["q1"]?.array?.first?.stringValue, "John")
    XCTAssertEqual(result["q2"]?.array?.first?["age"].stringValue, "13")
  }
}

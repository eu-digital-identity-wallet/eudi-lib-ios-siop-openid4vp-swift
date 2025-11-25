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

final class QueryIdTests: XCTestCase {

  func testQueryIdDescription() throws {
    let rawValue = "test-raw-value"
    let queryId = try QueryId(value: rawValue)

    let description = queryId.description

    XCTAssertEqual(description, rawValue)
  }

  func testEncodeToJSON() throws {
    let rawValue = "test-raw-value"
    let queryId = try QueryId(value: rawValue)

    let encodedData = try JSONEncoder().encode(queryId)
    let encodedString = String(data: encodedData, encoding: .utf8)

    XCTAssertEqual(encodedString, "\"\(rawValue)\"")
  }
}

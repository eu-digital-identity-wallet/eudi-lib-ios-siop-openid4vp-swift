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

import SwiftyJSON

final class DCQLRulesTests: XCTestCase {

  override func setUpWithError() throws {
  }

  override func tearDownWithError() throws {
  }

  func testGivenCredentialQueryIdWhenValuesAreIllegalThenThrowException() async throws {

    var didThrow = false
    let illegalIds = [
      "",
      "@@123a",
      "^&())_"
    ]

    do {
      for id in illegalIds {
        try _ = QueryId(value: id)
      }
      XCTFail("Expected an error to be thrown, but none was.")

    } catch {
      didThrow = true
    }

    XCTAssertTrue(didThrow, "Expected error was not thrown during iteration.")
  }

  func testWhenCredentialsIsEmptyExceptionIsThrown() {
    do {
      try _ = DCQL(credentials: [])
      XCTAssert(false, "DCQL cannot have an empty credentials attribute")
    } catch {
      XCTAssert(true)
    }
  }

  func testWhenCredentialsContainsDuplicateEntriesExceptionIsRaised() {
    do {
      let id = try QueryId(value: "id")
      _ = try DCQL(
        credentials: [
          .init(id: id, format: try Format.MsoMdoc(), meta: [:]),
          .init(id: id, format: try Format.SdJwtVc(), meta: [:])
        ]
      )
      XCTAssert(false, "CredentialQuery ids must be unique")
    } catch {
      XCTAssert(true)
    }
  }

  func testWhenCredentialsSetIsEmptyAnExceptionIsRaised() {
    do {
      _ = try DCQL(
        credentials: [
          .init(id: .init(value: "1"), format: try Format.MsoMdoc(), meta: [:]),
          .init(id: .init(value: "2"), format: try Format.SdJwtVc(), meta: [:])
        ],
        credentialSets: []
      )
      XCTAssert(false, "Credential sets cannot be empty when not nil")
    } catch {
      XCTAssert(true)
    }
  }
}

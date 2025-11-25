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

final class CoreTests: DiXCTest {

  func testFetcherCodableFailureDecodingGivenInvalidRemoteURL() async {

    struct TestCodable: Codable {
      let title: String
    }

    let fetcher = Fetcher<TestCodable>()
    let result = await fetcher.fetch(url: URL(string: "https://example.com")!)
    switch result {
    case .failure(let error):
      switch error {
      case .decodingError:
        XCTAssert(true)
        return
      default: break
      }
    default: break
    }
    XCTAssert(false)
  }
}

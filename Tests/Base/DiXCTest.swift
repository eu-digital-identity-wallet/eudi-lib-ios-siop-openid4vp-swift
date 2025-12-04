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
import XCTest

@testable import OpenID4VP

class DiXCTest: XCTestCase {

  override func setUp() async throws {
    overrideDependencies()
    try await super.setUp()
  }

  override func tearDown() {
    DependencyContainer.shared.removeAll()
    super.tearDown()
  }

  func testContainer() {
    let reporting = DependencyContainer.shared.resolve(
      type: Reporting.self,
      mode: .new
    )

    XCTAssert(reporting is MockReporter)
  }
}

extension DiXCTest {
  func overrideDependencies() {
    DependencyContainer.shared.register(type: Reporting.self, dependency: {
      MockReporter()
    })
  }
}

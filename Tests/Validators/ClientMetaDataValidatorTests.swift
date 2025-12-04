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

final class ClientMetaDataValidatorTests: XCTestCase {

  var validator: ClientMetaDataValidator!

  override func tearDown() {
    DependencyContainer.shared.removeAll()
    self.validator = nil
    super.tearDown()
  }

  override func setUp() {
    overrideDependencies()
    self.validator = ClientMetaDataValidator()
  }

  func testValidate_WhenFetchByReferenceWithValidURL_ThenReturnSuccess() async throws {

    do {
      let response: ClientMetaData.Validated = try await self.validator.validate(clientMetaData: .init(
        jwks: TestsConstants.webKeyJson,
        vpFormatsSupported: TestsConstants.testVpFormatsSupportedTO()
      ), responseMode: nil, responseEncryptionConfiguration: .unsupported)!

      XCTAssertEqual(response.jwkSet?.keys.first?.kty, TestsConstants.webKeySet.keys.first?.kty)
    } catch {

      XCTExpectFailure()
      XCTFail()
    }
  }

  func testValidate_WhenFetchByReferenceWithInvalidURL_ThenReturnFailure() async throws {

    do {
      let response: ClientMetaData.Validated = try await self.validator.validate(clientMetaData: .init(
        jwks: TestsConstants.webKeyJson,
        vpFormatsSupported: TestsConstants.testVpFormatsSupportedTO()
      ), responseMode: nil, responseEncryptionConfiguration: .unsupported)!

      XCTAssertEqual(response.jwkSet?.keys.first, TestsConstants.webKeySet.keys.first)

    } catch {
      XCTAssertTrue(error.localizedDescription == "Validation Error Client meta data has no valid JWK source")
    }
  }

  func testValidate_WhenPassByValue_ThenReturnSuccess() async throws {

    let response: ClientMetaData.Validated = try await self.validator.validate(clientMetaData: .init(
      jwks: TestsConstants.sampleValidJWKS,
      vpFormatsSupported: TestsConstants.testVpFormatsSupportedTO()
    ), responseMode: nil, responseEncryptionConfiguration: .unsupported)!

    XCTAssertNotNil(response.jwkSet?.keys.first)
  }
}

private extension ClientMetaDataValidatorTests {
  func overrideDependencies() {
    DependencyContainer.shared.register(type: Reporting.self, dependency: {
      Reporter()
    })
  }
}

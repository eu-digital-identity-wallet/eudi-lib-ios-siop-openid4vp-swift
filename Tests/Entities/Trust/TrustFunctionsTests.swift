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
import X509

final class TrustFunctionsTests: XCTestCase {

  func testParseCertificateDataWithValidAndInvalidBase64() {

    let validBase64 = "T3BlbklENFZQ=="
    let invalidBase64 = "not_base_64"
    let input = [validBase64, invalidBase64]

    let result = parseCertificateData(from: input)

    XCTAssertEqual(String(data: result[0], encoding: .utf8), "OpenID4VP")
  }
}

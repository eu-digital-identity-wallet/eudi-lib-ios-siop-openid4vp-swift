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

final class DIDTests: XCTestCase {

  private let sampleDidJwk =
  """
    did:jwk:
    eyJraWQiOiJ1cm46aWV0ZjpwYXJhbXM6b2F1dGg6andrLXRodW1icHJpbnQ6c2hhLTI
    1Njpnc0w0VTRxX1J6VFhRckpwQUNnZGkwb1lCdUV1QjNZNWZFanhDd1NPUFlBIiwia3
    R5IjoiRUMiLCJjcnYiOiJQLTM4NCIsImFsZyI6IkVTMzg0IiwieCI6ImEtRWV5T2hlR
    UNWcDJqRkdVRTNqR0RCNlAzVV80S0lyZHRzTU9RQXFQN0NBMlVvV3NERG1nOWdJUVhi
    OEthd0ciLCJ5Ijoib3cxWDJ6VFVRaG12elY4NnpHdGhKc0xLeDE2MmhmSmxmN1p0OTF
    YUnZBTzRScE4zR2RGaVl3Tmc0NXJWUmlUcSJ9
  """.replacingOccurrences(of: "\n", with: "")
     .trimmingCharacters(in: .whitespacesAndNewlines)
     .replacingOccurrences(of: " ", with: "")

  override func setUpWithError() throws {
  }

  override func tearDownWithError() throws {
  }

  func testValidDIDsShouldBeParsed() {
    let dids = [
      "did:ethr:mainnet:0x3b0bc51ab9de1e5b7b6e34e5b960285805c41736",
      "did:dns:danubetech.com",
      "did:key:zDnaerDaTF5BXEavCrfRZEk316dpbLsfPDZ3WJ5hRTPFU2169",
      "did:key:zQ3shokFTS3brHcDQrn82RUDfCZESWL1ZdCEJwekUDPQiYBme",
      "did:ebsi:ziE2n8Ckhi6ut5Z8Cexrihd",
      "did:eosio:4667b205c6838ef70ff7988f6e8257e8be0e1284a2f59699054a018f743b1d11:caleosblocks"
    ]

    dids.forEach { did in
      XCTAssertNotNil(DID.parse(did), "Failed to parse \(did)")
    }
  }

  func testSampleDIDsShouldBeParsed() {
    let dids = [
      sampleDidJwk
    ]

    dids.forEach { did in
      XCTAssertNotNil(DID.parse(did), "Failed to parse \(did)")
    }
  }

  func testInvalidDIDsShouldNotBeParsed() {

    let dids = [
      "didethr:mainnet:0x3b0bc51ab9de1e5b7b6e34e5b960285805c41736",
      "dns:danubetech.com",
      "did:   :zQ3shokFTS3brHcDQrn82RUDfCZESWL1ZdCEJwekUDPQiYBme",
      "did:jwk:   ",
      "did:example:123?service=agent&relativeRef=/credentials#degree",
      "did:example:123?service=agent&relativeRef=/credentials",
      "did:eosio:4667b205c6838ef70ff7988f6e8257e8be0e1284a2f59699054a018f743b1d11:caleosblocks#123"
    ]

    dids.forEach { did in
      XCTAssertNil(DID.parse(did), "Parsed should fail for \(did)")
    }
  }

  func testValidDIDURLsShouldBeParsedAsDIDURLs() {
    let didUrls = [
      "did:ethr:mainnet:0x3b0bc51ab9de1e5b7b6e34e5b960285805c41736#controller",
      "did:dns:danubetech.com#z6MkjvBkt8ETnxXGBFPSGgYKb43q7oNHLX8BiYSPcXVG6gY6",
      "did:key:zDnaerDaTF5BXEavCrfRZEk316dpbLsfPDZ3WJ5hRTPFU2169#zDnaerDaTF5BXEavCrfRZEk316dpbLsfPDZ3WJ5hRTPFU2169",
      "did:ebsi:ziE2n8Ckhi6ut5Z8Cexrihd#key-1",
      "did:example:123?service=agent&relativeRef=/credentials#degree",
      "did:eosio:4667b205c6838ef70ff7988f6e8257e8be0e1284a2f59699054a018f743b1d11:caleosblocks#123"
    ]

    didUrls.forEach { didUrl in
      XCTAssertNotNil(AbsoluteDIDUrl.parse(didUrl), "Failed to parse \(didUrl)")
    }
  }
}

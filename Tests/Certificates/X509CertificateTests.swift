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
import X509

@testable import SiopOpenID4VP

final class X509CertificateTests: XCTestCase {
  
  override func setUpWithError() throws {
  }
  
  override func tearDownWithError() throws {
  }
  
  func testSecKeyCreationFromX509Certificate() throws {
    
    if let data = Data(base64Encoded: TestsConstants.x5cCertificate) {
      let derBytes = [UInt8](data)
      let certificate = try Certificate(derEncoded: derBytes)
      
      let publicKey = certificate.publicKey
      let pem = try publicKey.serializeAsPEM().pemString
      
      let secKey = try KeyController.convertPEMToPublicKey(pem)
      XCTAssertNotNil(secKey)
      
      let clientIndentifier = "client_identifer.example.com"
      guard let dnss = try? certificate.extensions.subjectAlternativeNames?.rawSubjectAlternativeNames() else {
        XCTFail("Could not locate subject alternative names")
        return
      }
      XCTAssert(!dnss.isEmpty)
      XCTAssert(dnss.contains(where: { $0 == clientIndentifier }))

      let uri = "https://www.example.com"
      guard let uris = try? certificate.extensions.subjectAlternativeNames?.rawUniformResourceIdentifiers() else {
        XCTFail("Could not locate uri's")
        return
      }
      XCTAssert(!uris.isEmpty)
      XCTAssert(uris.contains(where: { $0 == uri }))
      
    } else {
      XCTFail("Could not get SecKey from base64 x509")
    }
  }
}

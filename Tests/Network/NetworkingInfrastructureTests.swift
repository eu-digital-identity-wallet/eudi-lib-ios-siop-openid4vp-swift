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

class SelfSignedSessionDelegateTests: DiXCTest {

  func testSelfSignedCertificateChallenge() {

    let delegate = SelfSignedSessionDelegate()
    let session = URLSession(
      configuration: .default,
      delegate: SelfSignedSessionDelegate(),
      delegateQueue: nil
    )

    let protectionSpace = URLProtectionSpace(
      host: "example.com",
      port: 443,
      protocol: NSURLProtectionSpaceHTTPS,
      realm: nil,
      authenticationMethod: NSURLAuthenticationMethodServerTrust
    )

    let challenge = URLAuthenticationChallenge(
      protectionSpace: protectionSpace,
      proposedCredential: nil,
      previousFailureCount: 0,
      failureResponse: nil,
      error: nil,
      sender: MockSender()
    )

    let expectation = XCTestExpectation(description: "Completion handler called")

    delegate.urlSession(session, didReceive: challenge) { disposition, credential in
      XCTAssertEqual(disposition, .cancelAuthenticationChallenge)
      XCTAssertNil(credential)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.0)
  }

  func testOtherAuthenticationMethodChallenge() {
    let delegate = SelfSignedSessionDelegate()
    let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)

    let protectionSpace = URLProtectionSpace(
        host: "example.com",
        port: 443,
        protocol: NSURLProtectionSpaceHTTPS,
        realm: nil,
        authenticationMethod: NSURLAuthenticationMethodDefault
    )

    let challenge = URLAuthenticationChallenge(
        protectionSpace: protectionSpace,
        proposedCredential: nil,
        previousFailureCount: 0,
        failureResponse: nil,
        error: nil,
        sender: MockSender()
    )

    let expectation = XCTestExpectation(description: "Completion handler called")

    delegate.urlSession(session, didReceive: challenge) { disposition, credential in
        XCTAssertEqual(disposition, .cancelAuthenticationChallenge)
        XCTAssertNil(credential)
        expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }
}

final class MockSender: NSObject, URLAuthenticationChallengeSender {
  func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {}
  func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {}
  func cancel(_ challenge: URLAuthenticationChallenge) {}
  func performDefaultHandling(for challenge: URLAuthenticationChallenge) {}
  func rejectProtectionSpaceAndContinue(with challenge: URLAuthenticationChallenge) {}
}

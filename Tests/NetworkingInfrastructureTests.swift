import XCTest

@testable import SiopOpenID4VP

class SelfSignedSessionDelegateTests: XCTestCase {

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

class MockSender: NSObject, URLAuthenticationChallengeSender {
  func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {}
  func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {}
  func cancel(_ challenge: URLAuthenticationChallenge) {}
  func performDefaultHandling(for challenge: URLAuthenticationChallenge) {}
  func rejectProtectionSpaceAndContinue(with challenge: URLAuthenticationChallenge) {}
}

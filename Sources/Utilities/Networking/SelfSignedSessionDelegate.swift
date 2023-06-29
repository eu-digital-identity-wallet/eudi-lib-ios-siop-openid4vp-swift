import Foundation

/**
  A custom `URLSessionDelegate` implementation to handle self-signed certificates.
*/
class SelfSignedSessionDelegate: NSObject, URLSessionDelegate {
  /**
    Handles the URL authentication challenge and provides a credential for self-signed certificates.

    - Parameters:
      - session: The session sending the request.
      - challenge: The authentication challenge to handle.
      - completionHandler: A completion handler to call with the disposition and credential.

    - Note: This method is called when the session receives an authentication challenge.
  */
  func urlSession(
    _ session: URLSession,
    didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
  ) {
    // Check if the challenge is for a self-signed certificate
    if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
       let trust = challenge.protectionSpace.serverTrust {
      // Create a URLCredential with the self-signed certificate
      let credential = URLCredential(trust: trust)
      // Call the completion handler with the credential to accept the self-signed certificate
      completionHandler(.useCredential, credential)
    } else {
      // For other authentication methods, call the completion handler with a nil credential to reject the request
      completionHandler(.cancelAuthenticationChallenge, nil)
    }
  }
}

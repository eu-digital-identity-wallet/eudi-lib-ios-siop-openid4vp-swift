import Foundation

/*
This enum represents a set of JOSE (Javascript Object Signing and Encryption) errors.
It conforms to the LocalizedError protocol so we can get a human-readable error description.
*/
public enum JOSEError: LocalizedError {
  // The error case representing an unsupported request
  case notSupportedRequest
  case invalidIdTokenRequest
  case invalidPublicKey
  case invalidJWS
  case invalidSigner
  case invalidVerifier

  // A computed property to provide a description for each error case
  public var errorDescription: String? {
    switch self {
    case .notSupportedRequest:
      return ".notSupportedRequest"
    case .invalidIdTokenRequest:
      return ".invalidIdTokenRequest"
    case .invalidPublicKey:
      return ".invalidPublicKey"
    case .invalidJWS:
      return ".invalidJWS"
    case .invalidSigner:
      return ".invalidSigner"
    case .invalidVerifier:
      return ".invalidVerifier"
    }
  }
}

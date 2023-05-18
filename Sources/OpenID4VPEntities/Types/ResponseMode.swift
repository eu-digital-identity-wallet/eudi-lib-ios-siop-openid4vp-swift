import Foundation
import PresentationExchange

public enum ResponseMode {
  case directPost(responseURI: URL)
  case directPostJWT(responseURI: URL)
  case query(responseURI: URL)
  case fragment(responseURI: URL)
  case none
}

extension ResponseMode {
  init(authorizationRequestObject: JSONObject) throws {
    guard
      let responseMode = authorizationRequestObject["response_mode"] as? String
    else {
      throw ValidatedAuthorizationError.missingRequiredField(".responseMode")
    }

    switch responseMode {
    case "direct_post":
      if let responseUri = authorizationRequestObject["response_uri"] as? String,
         let uri = URL(string: responseUri) {
        self = .directPost(responseURI: uri)
      } else {
        throw ValidatedAuthorizationError.missingRequiredField(".responseUri")
      }
    case "direct_post.jwt":
      if let responseUri = authorizationRequestObject["response_uri"] as? String,
         let uri = URL(string: responseUri) {
         self = .directPostJWT(responseURI: uri)
      } else {
        throw ValidatedAuthorizationError.missingRequiredField(".responseUri")
      }
    case "query":
      if let redirectUri = authorizationRequestObject["redirect_uri"] as? String,
         let uri = URL(string: redirectUri) {
        self = .query(responseURI: uri)
      } else {
        throw ValidatedAuthorizationError.missingRequiredField(".redirectUri")
      }
    case "fragment":
      if let redirectUri = authorizationRequestObject["redirect_uri"] as? String,
         let uri = URL(string: redirectUri) {
        self = .fragment(responseURI: uri)
      } else {
        throw ValidatedAuthorizationError.missingRequiredField(".redirectUri")
      }
    default:
      throw ValidatedAuthorizationError.unsupportedResponseMode(responseMode)
    }
  }

  init(authorizationRequestData: AuthorizationRequestUnprocessedData) throws {

    guard
      let responseMode = authorizationRequestData.responseMode
    else {
      throw ValidatedAuthorizationError.missingRequiredField(".responseMode")
    }

    switch responseMode {
    case "direct_post":
      if let responseUri = authorizationRequestData.responseUri,
         let uri = URL(string: responseUri) {
        self = .directPost(responseURI: uri)
      } else {
        throw ValidatedAuthorizationError.missingRequiredField(".responseUri")
      }
    case "direct_post.jwt":
      if let responseUri = authorizationRequestData.responseUri,
         let uri = URL(string: responseUri) {
         self = .directPostJWT(responseURI: uri)
      } else {
        throw ValidatedAuthorizationError.missingRequiredField(".responseUri")
      }
    case "query":
      if let redirectUri = authorizationRequestData.redirectUri,
         let uri = URL(string: redirectUri) {
        self = .query(responseURI: uri)
      } else {
        throw ValidatedAuthorizationError.missingRequiredField(".redirectUri")
      }
    case "fragment":
      if let redirectUri = authorizationRequestData.redirectUri,
         let uri = URL(string: redirectUri) {
        self = .fragment(responseURI: uri)
      } else {
        throw ValidatedAuthorizationError.missingRequiredField(".redirectUri")
      }
    default:
      throw ValidatedAuthorizationError.unsupportedResponseMode(responseMode)
    }
  }
}

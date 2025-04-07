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
import PresentationExchange
import SwiftyJSON

public enum ResponseMode {
  case directPost(responseURI: URL)
  case directPostJWT(responseURI: URL)
  case query(responseURI: URL)
  case fragment(responseURI: URL)
  case none

  /// Initializes a `ResponseMode` instance with the given authorization request object.
  ///
  /// - Parameter authorizationRequestObject: The authorization request object.
  /// - Throws: A `ValidatedAuthorizationError.missingRequiredField` if the required fields are missing,
  ///           or a `ValidatedAuthorizationError.unsupportedResponseMode` if the response mode is unsupported.
  public init(authorizationRequestObject: JSON) throws {
    guard let responseMode = authorizationRequestObject["response_mode"].string else {
      throw ValidationError.missingRequiredField(".responseMode")
    }

    switch responseMode {
    case "direct_post":
      if let responseUri = authorizationRequestObject["response_uri"].string,
         let uri = URL(string: responseUri) {
        self = .directPost(responseURI: uri)
      } else {
        throw ValidationError.missingRequiredField(".responseUri")
      }
    case "direct_post.jwt":
      if let responseUri = authorizationRequestObject["response_uri"].string,
         let uri = URL(string: responseUri) {
         self = .directPostJWT(responseURI: uri)
      } else {
        throw ValidationError.missingRequiredField(".responseUri")
      }
    case "query":
      if let redirectUri = authorizationRequestObject["redirect_uri"].string,
         let uri = URL(string: redirectUri) {
        self = .query(responseURI: uri)
      } else {
        throw ValidationError.missingRequiredField(".redirectUri")
      }
    case "fragment":
      if let redirectUri = authorizationRequestObject["redirect_uri"].string,
         let uri = URL(string: redirectUri) {
        self = .fragment(responseURI: uri)
      } else {
        throw ValidationError.missingRequiredField(".redirectUri")
      }
    default:
      throw ValidationError.unsupportedResponseMode(responseMode)
    }
  }

  /// Initializes a `ResponseMode` instance with the given authorization request data.
  ///
  /// - Parameter authorizationRequestData: The authorization request data.
  /// - Throws: A `ValidatedAuthorizationError.missingRequiredField` if the required fields are missing,
  ///           or a `ValidatedAuthorizationError.unsupportedResponseMode` if the response mode is unsupported.
  public init(authorizationRequestData: AuthorisationRequestObject) throws {
    guard let responseMode = authorizationRequestData.responseMode else {
      throw ValidationError.missingRequiredField(".responseMode")
    }

    switch responseMode {
    case "direct_post":
      if let responseUri = authorizationRequestData.responseUri,
         let uri = URL(string: responseUri) {
        self = .directPost(responseURI: uri)
      } else {
        throw ValidationError.missingRequiredField(".responseUri")
      }
    case "direct_post.jwt":
      if let responseUri = authorizationRequestData.responseUri,
         let uri = URL(string: responseUri) {
         self = .directPostJWT(responseURI: uri)
      } else {
        throw ValidationError.missingRequiredField(".responseUri")
      }
    case "query":
      if let redirectUri = authorizationRequestData.redirectUri,
         let uri = URL(string: redirectUri) {
        self = .query(responseURI: uri)
      } else {
        throw ValidationError.missingRequiredField(".redirectUri")
      }
    case "fragment":
      if let redirectUri = authorizationRequestData.redirectUri,
         let uri = URL(string: redirectUri) {
        self = .fragment(responseURI: uri)
      } else {
        throw ValidationError.missingRequiredField(".redirectUri")
      }
    default:
      throw ValidationError.unsupportedResponseMode(responseMode)
    }
  }
}

internal extension ResponseMode {
  func isJarm() -> Bool {
    switch self {
    case .directPost:
      return false
    case .directPostJWT:
      return true
    case .query:
      return false
    case .fragment:
      return false
    case .none:
      return false
    }
  }
}

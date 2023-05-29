import Foundation
import PresentationExchange

public enum ResponseType: String, Codable {
  case vpToken = "vp_token"
  case idToken = "id_token"
  case vpAndIdToken = "vp_token id_token"
  case code = "code"

  /// Initializes a `ResponseType` instance with the given authorization request object.
  ///
  /// - Parameter authorizationRequestObject: The authorization request object.
  /// - Throws: A `ValidatedAuthorizationError.unsupportedResponseType` if the response type is unsupported.
  public init(authorizationRequestObject: JSONObject) throws {
    let type = authorizationRequestObject["response_type"] as? String ?? ""
    guard let responseType = ResponseType(rawValue: type) else {
      throw ValidatedAuthorizationError.unsupportedResponseType(type.isEmpty ? "unknown" : type)
    }

    self = responseType
  }

  /// Initializes a `ResponseType` instance with the given authorization request data.
  ///
  /// - Parameter authorizationRequestData: The authorization request data.
  /// - Throws: A `ValidatedAuthorizationError.unsupportedResponseType` if the response type is unsupported.
  public init(authorizationRequestData: AuthorizationRequestUnprocessedData) throws {
    guard let responseType = ResponseType(rawValue: authorizationRequestData.responseType ?? "") else {
      throw ValidatedAuthorizationError.unsupportedResponseType(authorizationRequestData.responseType)
    }

    self = responseType
  }
}

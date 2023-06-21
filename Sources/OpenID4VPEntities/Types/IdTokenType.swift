import Foundation
import PresentationExchange

public enum IdTokenType: String, Codable {
  case subjectSignedIdToken = "subject_signed_id_token"
  case subjectSigned = "subject_signed"
  case attesterSigned = "attester_signed"

  /// Initializes an `IdTokenType` instance with the given authorization request object.
  ///
  /// - Parameter authorizationRequestObject: The authorization request object.
  /// - Throws: A `ValidatedAuthorizationError.invalidIdTokenType` if the id_token_type is missing,
  ///           or a `ValidatedAuthorizationError.unsupportedIdTokenType` if the id_token_type is unsupported.
  public init(authorizationRequestObject: JSONObject) throws {
    guard let idTokenType = authorizationRequestObject["id_token_type"] as? String else {
      throw ValidatedAuthorizationError.invalidIdTokenType
    }

    guard let responseType = IdTokenType(rawValue: idTokenType) else {
      throw ValidatedAuthorizationError.unsupportedIdTokenType(idTokenType)
    }

    self = responseType
  }

  /// Initializes an `IdTokenType` instance with the given authorization request data.
  ///
  /// - Parameter authorizationRequestData: The authorization request data.
  /// - Throws: A `ValidatedAuthorizationError.invalidIdTokenType` if the id_token_type is missing,
  ///           or a `ValidatedAuthorizationError.unsupportedIdTokenType` if the id_token_type is unsupported.
  public init(authorizationRequestData: AuthorizationRequestUnprocessedData) throws {
    guard let idTokenType = authorizationRequestData.idTokenType else {
      throw ValidatedAuthorizationError.invalidIdTokenType
    }

    guard let responseType = IdTokenType(rawValue: idTokenType) else {
      throw ValidatedAuthorizationError.unsupportedIdTokenType(authorizationRequestData.idTokenType)
    }

    self = responseType
  }
}

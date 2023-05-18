import Foundation
import PresentationExchange

public enum IdTokenType: String, Codable {
  case subjectSigned = "subject_signed"
  case attesterSigned = "attester_signed"
}

extension IdTokenType {
  init(authorizationRequestObject: JSONObject) throws {
    guard
      let idTokenType = authorizationRequestObject["id_token_type"] as? String
    else {
      throw ValidatedAuthorizationError.invalidIdTokenType
    }

    guard
      let responseType = IdTokenType(rawValue: idTokenType)
    else {
      throw ValidatedAuthorizationError.unsupportedIdTokenType(idTokenType)
    }

    self = responseType
  }

  init(authorizationRequestData: AuthorizationRequestUnprocessedData) throws {
    guard
      let idTokenType = authorizationRequestData.idTokenType
    else {
      throw ValidatedAuthorizationError.invalidIdTokenType
    }

    guard
      let responseType = IdTokenType(rawValue: idTokenType)
    else {
      throw ValidatedAuthorizationError.unsupportedIdTokenType(authorizationRequestData.idTokenType)
    }

    self = responseType
  }
}

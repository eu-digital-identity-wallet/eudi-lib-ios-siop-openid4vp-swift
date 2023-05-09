import Foundation

public enum IdTokenType: String, Codable {
  case subjectSigned = "subject_signed"
  case attesterSigned = "attester_signed"
}

extension IdTokenType {
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

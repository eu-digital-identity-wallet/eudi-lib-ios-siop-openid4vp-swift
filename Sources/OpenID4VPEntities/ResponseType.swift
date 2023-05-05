import Foundation

public enum ResponseType: String, Codable {
  case vpToken = "vp_token"
  case idToken = "id_token"
  case vpAndIdToken = "vp_token id_token"
  case code = "code"
}

extension ResponseType {
  init(authorizationRequestData: AuthorizationRequestUnprocessedData) throws {

    guard
      let responseType = authorizationRequestData.responseType
    else {
      throw ValidatedAuthorizationError.invalidResponseType
    }

    guard
      responseType == "vp_token",
      let responseType = ResponseType(rawValue: authorizationRequestData.responseType ?? "")
    else {
      throw ValidatedAuthorizationError.unsupportedResponseType(authorizationRequestData.responseType)
    }

    self = responseType
  }
}

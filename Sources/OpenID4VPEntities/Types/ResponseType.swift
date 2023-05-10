import Foundation

public enum ResponseType: String, Codable {
  case vpToken = "vp_token"
  case idToken = "id_token"
  case vpAndIdToken = "vp_token id_token"
  case code = "code"
}

extension ResponseType {
  init(authorizationRequestObject: JSONObject) throws {
    let type = authorizationRequestObject["response_type"] as? String ?? ""
    guard
      let responseType = ResponseType(rawValue: type)
    else {
      throw ValidatedAuthorizationError.unsupportedResponseType(type.isEmpty ? "unknown" : type)
    }

    self = responseType
  }

  init(authorizationRequestData: AuthorizationRequestUnprocessedData) throws {

    guard
      let responseType = ResponseType(rawValue: authorizationRequestData.responseType ?? "")
    else {
      throw ValidatedAuthorizationError.unsupportedResponseType(authorizationRequestData.responseType)
    }

    self = responseType
  }
}

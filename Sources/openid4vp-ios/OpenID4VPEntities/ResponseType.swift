import Foundation

public enum ResponseType: String, Codable {
  case vpToken = "vp_token"
  case IdToken = "id_token"
  case vpAndIdToken = "vp_token id_token"
  case code = "code"
}

extension ResponseType {
  init(authorizationRequestData: AuthorizationRequestData) throws {
    
    guard
      let responseType = authorizationRequestData.responseType
    else {
      throw ValidatedAuthorizationError.invalidResponseType
    }
    
    // TODO: Current scope support "vp_token" only, final score will include all cases
    
    guard
      responseType == "vp_token",
      let responseType = ResponseType(rawValue: authorizationRequestData.responseType ?? "")
    else {
      throw ValidatedAuthorizationError.unsupportedResponseType(authorizationRequestData.responseType)
    }
    
    self = responseType
  }
}

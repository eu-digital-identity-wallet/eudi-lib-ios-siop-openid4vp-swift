import Foundation

public enum ResponseMode {
  case directPost(responseURI: URL)
  case directPostJWT(responseURI: URL)
  case query(responseURI: URL)
  case fragment(responseURI: URL)
  case none
}

extension ResponseMode {
  init(authorizationRequestData: AuthorizationRequestUnprocessedData) throws {

    guard
      authorizationRequestData.responseMode != nil
    else {
      self = .none
      return
    }

    do {
      self = try ResponseMode(authorizationRequestData: authorizationRequestData)
    } catch {
      throw ValidatedAuthorizationError.unsupportedResponseMode(authorizationRequestData.responseType)
    }
  }
}

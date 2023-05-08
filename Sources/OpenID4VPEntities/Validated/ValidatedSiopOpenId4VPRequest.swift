import Foundation

public enum ValidatedSiopOpenId4VPRequest {
  case idToken(request: IdTokenRequest)
  case vpToken(request: VpTokenRequest)
  case idAndVpToken(request: IdAndVpTokenRequest)
}

public extension ValidatedSiopOpenId4VPRequest {
  init(authorizationRequestData: AuthorizationRequestUnprocessedData) throws {
    let responseType = try ResponseType(authorizationRequestData: authorizationRequestData)
    guard let nonce = authorizationRequestData.nonce else {
      throw ValidatedAuthorizationError.missingRequiredField(".nonce")
    }

    guard let clientId = authorizationRequestData.clientId else {
      throw ValidatedAuthorizationError.missingRequiredField(".clientId")
    }

    switch responseType {
    case .idToken:
      self = .idToken(request: .init(
        idTokenType: [
          try .init(authorizationRequestData: authorizationRequestData)
        ],
        clientMetaDataSource: .init(authorizationRequestData: authorizationRequestData),
        clientIdScheme: try .init(authorizationRequestData: authorizationRequestData),
        clientId: clientId,
        nonce: nonce,
        scope: authorizationRequestData.scope,
        responseMode: try .init(authorizationRequestData: authorizationRequestData),
        state: authorizationRequestData.state
      ))
    case .vpToken:
      self = .vpToken(request: .init(
        presentationDefinitionSource: try .init(authorizationRequestData: authorizationRequestData),
        clientMetaDataSource: .init(authorizationRequestData: authorizationRequestData),
        clientIdScheme: try .init(authorizationRequestData: authorizationRequestData),
        clientId: clientId,
        nonce: nonce,
        responseMode: try .init(authorizationRequestData: authorizationRequestData),
        state: authorizationRequestData.state
      ))
    case .vpAndIdToken:
      self = .idAndVpToken(request: .init(
        idTokenType: [
          try .init(authorizationRequestData: authorizationRequestData)
        ],
        presentationDefinitionSource: try .init(authorizationRequestData: authorizationRequestData),
        clientMetaDataSource: .init(authorizationRequestData: authorizationRequestData),
        clientIdScheme: try .init(authorizationRequestData: authorizationRequestData),
        clientId: clientId,
        nonce: nonce,
        scope: authorizationRequestData.scope,
        responseMode: try .init(authorizationRequestData: authorizationRequestData),
        state: authorizationRequestData.state
      ))
    case .code:
      throw ValidatedAuthorizationError.unsupportedResponseType(".code")
    }
  }
}

import Foundation

public enum ValidatedSiopOpenId4VPRequest {
  case idToken(request: IdTokenRequest)
  case vpToken(request: VpTokenRequest)
  case idAndVpToken(request: IdAndVpTokenRequest)
}

public extension ValidatedSiopOpenId4VPRequest {
  init(requestUri: JWTURI) async throws {
    guard let requestUrl = URL(string: requestUri) else {
      throw ValidatedAuthorizationError.invalidRequestUri(requestUri)
    }
    guard let token: RemoteJWT = try await Fetcher().fetch(url: requestUrl).get() else {
      throw ValidatedAuthorizationError.invalidJwtPayload
    }
    let jsonWebToken = JSONWebToken(jsonWebToken: token.jwt)
    guard let payload = jsonWebToken?.payload else { throw ValidatedAuthorizationError.invalidAuthorizationData }
    guard let clientId = payload["client_id"] as? String else {
      throw ValidatedAuthorizationError.missingRequiredField(".clientId")
    }
    guard let nonce = payload["nonce"] as? String else {
      throw ValidatedAuthorizationError.missingRequiredField(".nonce")
    }
    let responseType = try ResponseType(authorizationRequestObject: payload)

    switch responseType {
    case .idToken:
      self = .idToken(request: .init(
        idTokenType: [
          try .init(authorizationRequestObject: payload)
        ],
        clientMetaDataSource: .init(authorizationRequestObject: payload),
        clientIdScheme: try .init(authorizationRequestObject: payload),
        clientId: clientId,
        nonce: nonce,
        scope: payload["scope"] as? String ?? "",
        responseMode: try .init(authorizationRequestObject: payload),
        state: payload["state"] as? String
      ))
    case .vpToken:
      self = .vpToken(request: .init(
        presentationDefinitionSource: try .init(authorizationRequestObject: payload),
        clientMetaDataSource: .init(authorizationRequestObject: payload),
        clientIdScheme: try .init(authorizationRequestObject: payload),
        clientId: clientId,
        nonce: nonce,
        responseMode: try .init(authorizationRequestObject: payload),
        state: payload["state"] as? String
      ))
    case .vpAndIdToken:
      self = .idAndVpToken(request: .init(
        idTokenType: [
          try .init(authorizationRequestObject: payload)
        ],
        presentationDefinitionSource: try .init(authorizationRequestObject: payload),
        clientMetaDataSource: .init(authorizationRequestObject: payload),
        clientIdScheme: try .init(authorizationRequestObject: payload),
        clientId: clientId,
        nonce: nonce,
        scope: payload["scope"] as? String ?? "",
        responseMode: try .init(authorizationRequestObject: payload),
        state: payload["state"] as? String
      ))
    case .code:
      throw ValidatedAuthorizationError.unsupportedResponseType(".code")
    }
  }

  init(request: JWTString) throws {
    let jsonWebToken = JSONWebToken(jsonWebToken: request)
    guard let payload = jsonWebToken?.payload else { throw ValidatedAuthorizationError.invalidAuthorizationData }
    guard let clientId = payload["client_id"] as? String else {
      throw ValidatedAuthorizationError.missingRequiredField(".clientId")
    }
    guard let nonce = payload["nonce"] as? String else {
      throw ValidatedAuthorizationError.missingRequiredField(".nonce")
    }
    let responseType = try ResponseType(authorizationRequestObject: payload)

    switch responseType {
    case .idToken:
      self = .idToken(request: .init(
        idTokenType: [
          try .init(authorizationRequestObject: payload)
        ],
        clientMetaDataSource: .init(authorizationRequestObject: payload),
        clientIdScheme: try .init(authorizationRequestObject: payload),
        clientId: clientId,
        nonce: nonce,
        scope: payload["scope"] as? String ?? "",
        responseMode: try .init(authorizationRequestObject: payload),
        state: payload["state"] as? String
      ))
    case .vpToken:
      self = .vpToken(request: .init(
        presentationDefinitionSource: try .init(authorizationRequestObject: payload),
        clientMetaDataSource: .init(authorizationRequestObject: payload),
        clientIdScheme: try .init(authorizationRequestObject: payload),
        clientId: clientId,
        nonce: nonce,
        responseMode: try .init(authorizationRequestObject: payload),
        state: payload["state"] as? String
      ))
    case .vpAndIdToken:
      self = .idAndVpToken(request: .init(
        idTokenType: [
          try .init(authorizationRequestObject: payload)
        ],
        presentationDefinitionSource: try .init(authorizationRequestObject: payload),
        clientMetaDataSource: .init(authorizationRequestObject: payload),
        clientIdScheme: try .init(authorizationRequestObject: payload),
        clientId: clientId,
        nonce: nonce,
        scope: payload["scope"] as? String ?? "",
        responseMode: try .init(authorizationRequestObject: payload),
        state: payload["state"] as? String
      ))
    case .code:
      throw ValidatedAuthorizationError.unsupportedResponseType(".code")
    }
  }

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

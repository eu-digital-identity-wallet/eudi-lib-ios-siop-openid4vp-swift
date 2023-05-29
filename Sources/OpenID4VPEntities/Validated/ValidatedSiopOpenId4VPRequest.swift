import Foundation
import PresentationExchange

// Enum defining the types of validated SIOP OpenID4VP requests
public enum ValidatedSiopOpenId4VPRequest {
  case idToken(request: IdTokenRequest)
  case vpToken(request: VpTokenRequest)
  case idAndVpToken(request: IdAndVpTokenRequest)
}

// Extension for ValidatedSiopOpenId4VPRequest
public extension ValidatedSiopOpenId4VPRequest {
  // Initialize with a request URI
  init(requestUri: JWTURI) async throws {
    // Convert request URI to URL
    guard let requestUrl = URL(string: requestUri) else {
      throw ValidatedAuthorizationError.invalidRequestUri(requestUri)
    }

    // Fetch the remote JWT using Fetcher
    guard let token: RemoteJWT = try await Fetcher().fetch(url: requestUrl).get() else {
      throw ValidatedAuthorizationError.invalidJwtPayload
    }

    // Extract the payload from the JSON Web Token
    guard let payload = JSONWebToken(jsonWebToken: token.jwt)?.payload else {
      throw ValidatedAuthorizationError.invalidAuthorizationData
    }

    // Extract the client ID and nonce from the payload
    guard let clientId = payload[Constants.CLIENT_ID] as? String else {
      throw ValidatedAuthorizationError.missingRequiredField(".clientId")
    }
    guard let nonce = payload[Constants.NONCE] as? String else {
      throw ValidatedAuthorizationError.missingRequiredField(".nonce")
    }

    // Determine the response type from the payload
    let responseType = try ResponseType(authorizationRequestObject: payload)

    // Initialize the validated request based on the response type
    switch responseType {
    case .idToken:
      self = try ValidatedSiopOpenId4VPRequest.createIdToken(
        clientId: clientId,
        nonce: nonce,
        authorizationRequestObject: payload
      )
    case .vpToken:
      self = try ValidatedSiopOpenId4VPRequest.createVpToken(
        clientId: clientId,
        nonce: nonce,
        authorizationRequestObject: payload
      )
    case .vpAndIdToken:
      self = try ValidatedSiopOpenId4VPRequest.createIdVpToken(
        clientId: clientId,
        nonce: nonce,
        authorizationRequestObject: payload
      )
    case .code:
      throw ValidatedAuthorizationError.unsupportedResponseType(".code")
    }
  }

  // Initialize with a JWT string
  init(request: JWTString) throws {
    // Create a JSONWebToken from the JWT string
    let jsonWebToken = JSONWebToken(jsonWebToken: request)

    // Extract the payload from the JSON Web Token
    guard let payload = jsonWebToken?.payload else {
      throw ValidatedAuthorizationError.invalidAuthorizationData
    }

    // Extract the client ID and nonce from the payload
    guard let clientId = payload[Constants.CLIENT_ID] as? String else {
      throw ValidatedAuthorizationError.missingRequiredField(".clientId")
    }
    guard let nonce = payload[Constants.NONCE] as? String else {
      throw ValidatedAuthorizationError.missingRequiredField(".nonce")
    }

    // Determine the response type from the payload
    let responseType = try ResponseType(authorizationRequestObject: payload)

    // Initialize the validated request based on the response type
    switch responseType {
    case .idToken:
      self = try ValidatedSiopOpenId4VPRequest.createIdToken(
        clientId: clientId,
        nonce: nonce,
        authorizationRequestObject: payload
      )
    case .vpToken:
      self = try ValidatedSiopOpenId4VPRequest.createVpToken(
        clientId: clientId,
        nonce: nonce,
        authorizationRequestObject: payload
      )
    case .vpAndIdToken:
      self = try ValidatedSiopOpenId4VPRequest.createIdVpToken(
        clientId: clientId,
        nonce: nonce,
        authorizationRequestObject: payload
      )
    case .code:
      throw ValidatedAuthorizationError.unsupportedResponseType(".code")
    }
  }

  // Initialize with an AuthorizationRequestUnprocessedData object
  init(authorizationRequestData: AuthorizationRequestUnprocessedData) async throws {
    if let request = authorizationRequestData.request {
      try self.init(request: request)
    } else if let requestUrl = authorizationRequestData.requestUri {
      try await self.init(requestUri: requestUrl)
    } else {
      // Determine the response type from the authorization request data
      let responseType = try ResponseType(authorizationRequestData: authorizationRequestData)

      // Extract the nonce from the authorization request data
      guard let nonce = authorizationRequestData.nonce else {
        throw ValidatedAuthorizationError.missingRequiredField(".nonce")
      }

      // Extract the client ID from the authorization request data
      guard let clientId = authorizationRequestData.clientId else {
        throw ValidatedAuthorizationError.missingRequiredField(".clientId")
      }

      // Initialize the validated request based on the response type
      switch responseType {
      case .idToken:
        self = .idToken(request: .init(
          idTokenType: try .init(authorizationRequestData: authorizationRequestData),
          clientMetaDataSource: .init(authorizationRequestData: authorizationRequestData),
          clientIdScheme: try .init(authorizationRequestData: authorizationRequestData),
          clientId: clientId,
          nonce: nonce,
          scope: authorizationRequestData.scope,
          responseMode: try? .init(authorizationRequestData: authorizationRequestData),
          state: authorizationRequestData.state
        ))
      case .vpToken:
        self = try ValidatedSiopOpenId4VPRequest.createVpToken(
          clientId: clientId,
          nonce: nonce,
          authorizationRequestData: authorizationRequestData
        )
      case .vpAndIdToken:
        self = .idAndVpToken(request: .init(
          idTokenType: try .init(authorizationRequestData: authorizationRequestData),
          presentationDefinitionSource: try .init(authorizationRequestData: authorizationRequestData),
          clientMetaDataSource: .init(authorizationRequestData: authorizationRequestData),
          clientIdScheme: try .init(authorizationRequestData: authorizationRequestData),
          clientId: clientId,
          nonce: nonce,
          scope: authorizationRequestData.scope,
          responseMode: try? .init(authorizationRequestData: authorizationRequestData),
          state: authorizationRequestData.state
        ))
      case .code:
        throw ValidatedAuthorizationError.unsupportedResponseType(".code")
      }
    }
  }
}

// Private extension for ValidatedSiopOpenId4VPRequest
private extension ValidatedSiopOpenId4VPRequest {
  // Create a VP token request
  static func createVpToken(
    clientId: String,
    nonce: String,
    authorizationRequestData: AuthorizationRequestUnprocessedData
  ) throws -> ValidatedSiopOpenId4VPRequest {
    .vpToken(request: .init(
      presentationDefinitionSource: try .init(authorizationRequestData: authorizationRequestData),
      clientMetaDataSource: .init(authorizationRequestData: authorizationRequestData),
      clientIdScheme: try .init(authorizationRequestData: authorizationRequestData),
      clientId: clientId,
      nonce: nonce,
      responseMode: try? .init(authorizationRequestData: authorizationRequestData),
      state: authorizationRequestData.state
    ))
  }

  // Create an ID token request
  static func createIdToken(
    clientId: String,
    nonce: String,
    authorizationRequestObject: JSONObject
  ) throws -> ValidatedSiopOpenId4VPRequest {
    .idToken(request: .init(
      idTokenType: try .init(authorizationRequestObject: authorizationRequestObject),
      clientMetaDataSource: .init(authorizationRequestObject: authorizationRequestObject),
      clientIdScheme: try .init(authorizationRequestObject: authorizationRequestObject),
      clientId: clientId,
      nonce: nonce,
      scope: authorizationRequestObject[Constants.SCOPE] as? String ?? "",
      responseMode: try? .init(authorizationRequestObject: authorizationRequestObject),
      state: authorizationRequestObject[Constants.STATE] as? String
    ))
  }

  // Create a VP token request
  static func createVpToken(
    clientId: String,
    nonce: String,
    authorizationRequestObject: JSONObject
  ) throws -> ValidatedSiopOpenId4VPRequest {
    .vpToken(request: .init(
      presentationDefinitionSource: try .init(authorizationRequestObject: authorizationRequestObject),
      clientMetaDataSource: .init(authorizationRequestObject: authorizationRequestObject),
      clientIdScheme: try .init(authorizationRequestObject: authorizationRequestObject),
      clientId: clientId,
      nonce: nonce,
      responseMode: try? .init(authorizationRequestObject: authorizationRequestObject),
      state: authorizationRequestObject[Constants.STATE] as? String
    ))
  }

  // Create an ID and VP token request
  static func createIdVpToken(
    clientId: String,
    nonce: String,
    authorizationRequestObject: JSONObject
  ) throws -> ValidatedSiopOpenId4VPRequest {
    .idAndVpToken(request: .init(
      idTokenType: try .init(authorizationRequestObject: authorizationRequestObject),
      presentationDefinitionSource: try .init(authorizationRequestObject: authorizationRequestObject),
      clientMetaDataSource: .init(authorizationRequestObject: authorizationRequestObject),
      clientIdScheme: try .init(authorizationRequestObject: authorizationRequestObject),
      clientId: clientId,
      nonce: nonce,
      scope: authorizationRequestObject[Constants.SCOPE] as? String ?? "",
      responseMode: try? .init(authorizationRequestObject: authorizationRequestObject),
      state: authorizationRequestObject[Constants.STATE] as? String
    ))
  }
}

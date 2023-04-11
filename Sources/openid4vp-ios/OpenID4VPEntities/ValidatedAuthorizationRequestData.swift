import Foundation

public enum ResponseType: String, Codable {
  case vpToken = "vp_token"
  case IdToken = "id_token"
  case vpAndIdToken = "vp_token_id_token"
  case code = "code"
  
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

/*
 * https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-additional-verifier-metadat
 */
public enum ClientIdScheme: String, Codable {
  case preRegistered = "pre-registered"
  case redirectUri = "redirect_uri"
  case entityId = "entity_id"
  case did = "did"
  
  init(authorizationRequestData: AuthorizationRequestData) throws {
    guard
      authorizationRequestData.clientIdScheme == "pre-registered",
      let clientIdScheme = ClientIdScheme(rawValue: authorizationRequestData.clientIdScheme ?? "")
    else {
      throw ValidatedAuthorizationError.unsupportedClientIdScheme(authorizationRequestData.clientIdScheme)
    }
    
    self = clientIdScheme
  }
}

public enum ClientMetaDataSource {
  case passByValue(metaData: ClientMetaData)
  case fetchByReference(url: URL)
  
  init?(authorizationRequestData: AuthorizationRequestData) {
    if let clientMetaData = authorizationRequestData.clientMetaData {
      self = .passByValue(metaData: clientMetaData)
    } else if let clientMetadataUri = authorizationRequestData.clientMetadataUri,
              let uri = URL(string: clientMetadataUri),
              uri.scheme == "https" {
      self = .fetchByReference(url: uri)
    } else {
      return nil
    }
  }
}

public enum ResponseMode {
  case directPost(responseURI: URL)
  case none
}

public struct ValidatedAuthorizationRequestData {
  let responseType: ResponseType
  let presentationDefinitionSource: PresentationDefinitionSource?
  let clientMetaDataSource: ClientMetaDataSource?
  let clientIdScheme: ClientIdScheme?
  let nonce: Nonce
  let scope: Scope?
  let responseMode: ResponseMode
  
  public init(
    responseType: ResponseType,
    presentationDefinitionSource: PresentationDefinitionSource?,
    clientMetaDataSource: ClientMetaDataSource?,
    clientIdScheme: ClientIdScheme?,
    nonce: Nonce,
    scope: Scope?,
    responseMode: ResponseMode) {
    self.responseType = responseType
    self.presentationDefinitionSource = presentationDefinitionSource
    self.clientMetaDataSource = clientMetaDataSource
    self.clientIdScheme = clientIdScheme
    self.nonce = nonce
    self.scope = scope
    self.responseMode = responseMode
  }
  
  init(authorizationRequestData: AuthorizationRequestData?) throws {
    guard
      let authorizationRequestData = authorizationRequestData
    else {
      throw ValidatedAuthorizationError.noAuthorizationData
    }
    
    self.init(
      responseType: try .init(authorizationRequestData: authorizationRequestData),
      presentationDefinitionSource: try .init(authorizationRequestData: authorizationRequestData),
      clientMetaDataSource: .init(authorizationRequestData: authorizationRequestData),
      clientIdScheme: try .init(authorizationRequestData: authorizationRequestData),
      nonce: "",
      scope: "",
      responseMode: .none
    )
  }
}

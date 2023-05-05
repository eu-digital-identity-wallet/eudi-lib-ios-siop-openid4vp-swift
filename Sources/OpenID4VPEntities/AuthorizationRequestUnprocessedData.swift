import Foundation

public enum IdTokenType: String, Codable {
  case subjectSigned = "subject_signed"
  case attesterSigned = "attester_signed"
}

/*
 *
 * https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-authorization-request
 */
public struct AuthorizationRequestUnprocessedData: Codable {

  let responseType: String?
  let responseUri: String?
  let redirectUri: String?
  let presentationDefinition: String?
  let presentationDefinitionUri: String?
  let request: String?
  let requestUri: String?
  let clientMetaData: JSONObject?
  let clientId: String?
  let clientMetadataUri: String?
  let clientIdScheme: String?
  let nonce: String?
  let scope: String?
  let responseMode: String?
  let state: String? // OpenId4VP specific, not utilized from ISO-23330-4
  let idTokenType: String?

  enum CodingKeys: String, CodingKey {
    case responseType = "response_type"
    case responseUri = "response_uri"
    case redirectUri = "redirect_uri"
    case presentationDefinition = "presentation_definition"
    case presentationDefinitionUri = "presentation_definition_uri"
    case clientId = "client_id"
    case clientMetaData = "client_meta_data"
    case clientMetadataUri = "client_metadata_uri"
    case clientIdScheme = "client_id_scheme"
    case nonce
    case scope
    case responseMode = "response_mode"
    case state = "state"
    case idTokenType = "id_token_type"
    case request
    case requestUri = "request_uri"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    responseType = try? container.decode(String.self, forKey: .responseType)
    responseUri = try? container.decode(String.self, forKey: .responseUri)
    redirectUri = try? container.decode(String.self, forKey: .redirectUri)

    presentationDefinition = try? container.decode(String.self, forKey: .presentationDefinition)
    presentationDefinitionUri = try? container.decode(String.self, forKey: .presentationDefinitionUri)

    clientId = try? container.decode(String.self, forKey: .clientId)
    clientMetaData = try? container.decode(JSONObject.self, forKey: .clientMetaData)
    clientMetadataUri = try? container.decode(String.self, forKey: .clientMetadataUri)

    clientIdScheme = try? container.decode(String.self, forKey: .clientIdScheme)
    nonce = try? container.decode(String.self, forKey: .nonce)
    scope = try? container.decode(String.self, forKey: .scope)
    responseMode = try? container.decode(String.self, forKey: .responseMode)
    state = try? container.decode(String.self, forKey: .state)

    idTokenType = try? container.decode(String.self, forKey: .idTokenType)

    request = try? container.decode(String.self, forKey: .request)
    requestUri = try? container.decode(String.self, forKey: .requestUri)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try? container.encode(responseType, forKey: .responseType)
    try? container.encode(responseUri, forKey: .responseUri)
    try? container.encode(redirectUri, forKey: .redirectUri)

    try? container.encode(presentationDefinition, forKey: .presentationDefinition)
    try? container.encode(presentationDefinitionUri, forKey: .presentationDefinitionUri)

    try? container.encode(clientId, forKey: .clientId)
    try? container.encode(clientMetaData, forKey: .clientMetaData)
    try? container.encode(clientMetadataUri, forKey: .clientMetadataUri)

    try? container.encode(clientIdScheme, forKey: .clientIdScheme)
    try? container.encode(nonce, forKey: .nonce)
    try? container.encode(scope, forKey: .scope)
    try? container.encode(responseMode, forKey: .responseMode)
    try? container.encode(state, forKey: .state)

    try? container.encode(idTokenType, forKey: .idTokenType)

    try? container.encode(request, forKey: .request)
    try? container.encode(requestUri, forKey: .requestUri)
  }
}

extension AuthorizationRequestUnprocessedData {
  public init?(from url: URL) {
    let parameters = url.queryParameters

    responseType = parameters?[CodingKeys.responseType.rawValue] as? String
    responseUri = parameters?[CodingKeys.responseUri.rawValue] as? String
    redirectUri = parameters?[CodingKeys.redirectUri.rawValue] as? String

    presentationDefinition = parameters?[CodingKeys.presentationDefinition.rawValue] as? String
    presentationDefinitionUri = parameters?[CodingKeys.presentationDefinitionUri.rawValue] as? String

    clientId = parameters?[CodingKeys.clientId.rawValue] as? String
    clientMetaData = parameters?[CodingKeys.clientMetaData.rawValue] as? JSONObject
    clientMetadataUri = parameters?[CodingKeys.clientMetadataUri.rawValue] as? String

    clientIdScheme = parameters?[CodingKeys.clientIdScheme.rawValue] as? String
    nonce = parameters?[CodingKeys.nonce.rawValue] as? String
    scope = parameters?[CodingKeys.scope.rawValue] as? String
    responseMode = parameters?[CodingKeys.responseMode.rawValue] as? String
    state = parameters?[CodingKeys.state.rawValue] as? String

    idTokenType = parameters?[CodingKeys.idTokenType.rawValue] as? String

    request = parameters?[CodingKeys.request.rawValue] as? String
    requestUri = parameters?[CodingKeys.requestUri.rawValue] as? String
  }
}

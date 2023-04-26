import Foundation

/*
 *
 * https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-authorization-request
 */
public struct AuthorizationRequestData: Codable {
  let responseType: String?
  let presentationDefinition: String?
  let presentationDefinitionUri: String?
  let clientMetaData: JSONObject?
  let clientMetadataUri: String?
  let clientIdScheme: String?
  let nonce: String?
  let scope: String?
  let responseMode: String?

  // Missing keys
  // OpenIdVP auth request is from an OAuth2.0
  // For the full set of attributes look up the OAuth2.0 spec
  enum CodingKeys: String, CodingKey {
    case responseType = "response_type"
    case presentationDefinition = "presentation_definition"
    case presentationDefinitionUri = "presentation_definition_uri"
    case clientMetaData = "client_meta_data"
    case clientMetadataUri = "client_metadata_uri"
    case clientIdScheme = "client_id_scheme"
    case nonce
    case scope
    case responseMode = "response_mode"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    responseType = try? container.decode(String.self, forKey: .responseType)
    presentationDefinition = try? container.decode(String.self, forKey: .presentationDefinition)
    presentationDefinitionUri = try? container.decode(String.self, forKey: .presentationDefinitionUri)
    clientMetaData = try? container.decode(JSONObject.self, forKey: .clientMetaData)
    clientMetadataUri = try? container.decode(String.self, forKey: .clientMetadataUri)
    clientIdScheme = try? container.decode(String.self, forKey: .clientIdScheme)
    nonce = try? container.decode(String.self, forKey: .nonce)
    scope = try? container.decode(String.self, forKey: .scope)
    responseMode = try? container.decode(String.self, forKey: .responseMode)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try? container.encode(responseType, forKey: .responseType)
    try? container.encode(presentationDefinition, forKey: .presentationDefinition)
    try? container.encode(presentationDefinitionUri, forKey: .presentationDefinitionUri)
    try? container.encode(clientMetaData, forKey: .clientMetaData)
    try? container.encode(clientMetadataUri, forKey: .clientMetadataUri)
    try? container.encode(clientIdScheme, forKey: .clientIdScheme)
    try? container.encode(nonce, forKey: .nonce)
    try? container.encode(scope, forKey: .scope)
    try? container.encode(responseMode, forKey: .responseMode)
  }
}

extension AuthorizationRequestData {
  public init?(from url: URL) {
    let parameters = url.queryParameters
    responseType = parameters?[CodingKeys.responseType.rawValue] as? String
    presentationDefinition = parameters?[CodingKeys.presentationDefinition.rawValue] as? String
    presentationDefinitionUri = parameters?[CodingKeys.presentationDefinitionUri.rawValue] as? String
    clientMetaData = parameters?[CodingKeys.clientMetaData.rawValue] as? JSONObject
    clientMetadataUri = parameters?[CodingKeys.clientMetadataUri.rawValue] as? String
    clientIdScheme = parameters?[CodingKeys.clientIdScheme.rawValue] as? String
    nonce = parameters?[CodingKeys.nonce.rawValue] as? String
    scope = parameters?[CodingKeys.scope.rawValue] as? String
    responseMode = parameters?[CodingKeys.responseMode.rawValue] as? String
  }
}

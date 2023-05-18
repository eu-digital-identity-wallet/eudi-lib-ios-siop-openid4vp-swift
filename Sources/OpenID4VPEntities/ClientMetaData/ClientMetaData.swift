import Foundation
import PresentationExchange

// By OpenID Connect Dynamic Client Registration specification
public struct ClientMetaData: Codable, Equatable {
  public let jwksUri: String
  public let idTokenSignedResponseAlg: String
  public let idTokenEncryptedResponseAlg: String
  public let idTokenEncryptedResponseEnc: String
  public let subjectSyntaxTypesSupported: [String]

  enum CodingKeys: String, CodingKey {
    case jwksUri = "jwks_uri"
    case idTokenSignedResponseAlg = "id_token_signed_response_alg"
    case idTokenEncryptedResponseAlg = "id_token_encrypted_response_alg"
    case idTokenEncryptedResponseEnc = "id_token_encrypted_response_enc"
    case subjectSyntaxTypesSupported = "subject_syntax_types_supported"
  }

  public init(
    jwksUri: String,
    idTokenSignedResponseAlg: String,
    idTokenEncryptedResponseAlg: String,
    idTokenEncryptedResponseEnc: String,
    subjectSyntaxTypesSupported: [String]
  ) {
    self.jwksUri = jwksUri
    self.idTokenSignedResponseAlg = idTokenSignedResponseAlg
    self.idTokenEncryptedResponseAlg = idTokenEncryptedResponseAlg
    self.idTokenEncryptedResponseEnc = idTokenEncryptedResponseEnc
    self.subjectSyntaxTypesSupported = subjectSyntaxTypesSupported
  }

  public init(metaData: JSONObject) throws {
    self.jwksUri = try getStringValue(from: metaData, for: "jwks_uri")
    self.idTokenSignedResponseAlg = try getStringValue(from: metaData, for: "id_token_signed_response_alg")
    self.idTokenEncryptedResponseAlg = try getStringValue(from: metaData, for: "id_token_encrypted_response_alg")
    self.idTokenEncryptedResponseEnc = try getStringValue(from: metaData, for: "id_token_encrypted_response_enc")
    self.subjectSyntaxTypesSupported = try getStringArrayValue(from: metaData, for: "subject_syntax_types_supported")
  }

  public init(metaDataString: String) throws {
    guard let metaData = try metaDataString.convertToDictionary() else {
      throw ValidatedAuthorizationError.invalidClientMetadata
    }

    self.jwksUri = try getStringValue(from: metaData, for: "jwks_uri")
    self.idTokenSignedResponseAlg = try getStringValue(from: metaData, for: "id_token_signed_response_alg")
    self.idTokenEncryptedResponseAlg = try getStringValue(from: metaData, for: "id_token_encrypted_response_alg")
    self.idTokenEncryptedResponseEnc = try getStringValue(from: metaData, for: "id_token_encrypted_response_enc")
    self.subjectSyntaxTypesSupported = try getStringArrayValue(from: metaData, for: "subject_syntax_types_supported")
  }
}

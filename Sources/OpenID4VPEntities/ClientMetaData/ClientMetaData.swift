import Foundation
import PresentationExchange

/// By OpenID Connect Dynamic Client Registration specification
/// A structure representing client metadata.
public struct ClientMetaData: Codable, Equatable {
  public let jwksUri: String
  public let idTokenSignedResponseAlg: String
  public let idTokenEncryptedResponseAlg: String
  public let idTokenEncryptedResponseEnc: String
  public let subjectSyntaxTypesSupported: [String]

  /// Coding keys for encoding and decoding the structure.
  enum CodingKeys: String, CodingKey {
    case jwksUri = "jwks_uri"
    case idTokenSignedResponseAlg = "id_token_signed_response_alg"
    case idTokenEncryptedResponseAlg = "id_token_encrypted_response_alg"
    case idTokenEncryptedResponseEnc = "id_token_encrypted_response_enc"
    case subjectSyntaxTypesSupported = "subject_syntax_types_supported"
  }

  /// Initializes a `ClientMetaData` instance with the provided values.
  /// - Parameters:
  ///   - jwksUri: The JWKS URI.
  ///   - idTokenSignedResponseAlg: The ID token signed response algorithm.
  ///   - idTokenEncryptedResponseAlg: The ID token encrypted response algorithm.
  ///   - idTokenEncryptedResponseEnc: The ID token encrypted response encryption.
  ///   - subjectSyntaxTypesSupported: The subject syntax types supported.
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

  /// Initializes a `ClientMetaData` instance with the provided JSON object representing metadata.
  /// - Parameter metaData: The JSON object representing the metadata.
  /// - Throws: An error if the required values are missing or invalid in the metadata.
  public init(metaData: JSONObject) throws {
    self.jwksUri = try getStringValue(from: metaData, for: "jwks_uri")
    self.idTokenSignedResponseAlg = try getStringValue(from: metaData, for: "id_token_signed_response_alg")
    self.idTokenEncryptedResponseAlg = try getStringValue(from: metaData, for: "id_token_encrypted_response_alg")
    self.idTokenEncryptedResponseEnc = try getStringValue(from: metaData, for: "id_token_encrypted_response_enc")
    self.subjectSyntaxTypesSupported = try getStringArrayValue(from: metaData, for: "subject_syntax_types_supported")
  }

  /// Initializes a `ClientMetaData` instance with the provided metadata string.
  /// - Parameter metaDataString: The string representing the metadata.
  /// - Throws: An error if the metadata string is invalid or cannot be converted to a dictionary.
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

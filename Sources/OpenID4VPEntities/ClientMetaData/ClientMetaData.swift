/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import Foundation

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
    self.jwksUri = try metaData.getValue(
      for: "jwks_uri",
      error: ValidatedAuthorizationError.invalidClientMetadata
    )
    self.idTokenSignedResponseAlg = try metaData.getValue(
      for: "id_token_signed_response_alg",
      error: ValidatedAuthorizationError.invalidClientMetadata
    )
    self.idTokenEncryptedResponseAlg = try metaData.getValue(
      for: "id_token_encrypted_response_alg",
      error: ValidatedAuthorizationError.invalidClientMetadata
    )
    self.idTokenEncryptedResponseEnc = try metaData.getValue(
      for: "id_token_encrypted_response_enc",
      error: ValidatedAuthorizationError.invalidClientMetadata
    )
    self.subjectSyntaxTypesSupported = try metaData.getValue(
      for: "subject_syntax_types_supported",
      error: ValidatedAuthorizationError.invalidClientMetadata
    )
  }

  /// Initializes a `ClientMetaData` instance with the provided metadata string.
  /// - Parameter metaDataString: The string representing the metadata.
  /// - Throws: An error if the metadata string is invalid or cannot be converted to a dictionary.
  public init(metaDataString: String) throws {
    guard let metaData = try metaDataString.convertToDictionary() else {
      throw ValidatedAuthorizationError.invalidClientMetadata
    }
    self.jwksUri = try metaData.getValue(
      for: "jwks_uri",
      error: ValidatedAuthorizationError.invalidClientMetadata
    )
    self.idTokenSignedResponseAlg = try metaData.getValue(
      for: "id_token_signed_response_alg",
      error: ValidatedAuthorizationError.invalidClientMetadata
    )
    self.idTokenEncryptedResponseAlg = try metaData.getValue(
      for: "id_token_encrypted_response_alg",
      error: ValidatedAuthorizationError.invalidClientMetadata
    )
    self.idTokenEncryptedResponseEnc = try metaData.getValue(
      for: "id_token_encrypted_response_enc",
      error: ValidatedAuthorizationError.invalidClientMetadata
    )
    self.subjectSyntaxTypesSupported = try metaData.getValue(
      for: "subject_syntax_types_supported",
      error: ValidatedAuthorizationError.invalidClientMetadata
    )
  }
}

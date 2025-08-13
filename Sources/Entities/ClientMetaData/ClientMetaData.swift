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
import SwiftyJSON

/// By OpenID Connect Dynamic Client Registration specification
/// A structure representing client metadata.
public struct ClientMetaData: Codable, Equatable, Sendable {

  static let vpFormats = "vp_formats"

  public let jwks: String?
  public let idTokenSignedResponseAlg: String?
  public let idTokenEncryptedResponseAlg: String?
  public let idTokenEncryptedResponseEnc: String?
  public let subjectSyntaxTypesSupported: [String]
  public let vpFormats: VpFormatsTO?
  public let responseEncryptionMethodsSupported: [String]?
  
  /// Coding keys for encoding and decoding the structure.
  enum CodingKeys: String, CodingKey {
    case jwks = "jwks"
    case idTokenSignedResponseAlg = "id_token_signed_response_alg"
    case idTokenEncryptedResponseAlg = "id_token_encrypted_response_alg"
    case idTokenEncryptedResponseEnc = "id_token_encrypted_response_enc"
    case subjectSyntaxTypesSupported = "subject_syntax_types_supported"
    case vpFormats = "vp_formats"
    case responseEncryptionMethodsSupported = "encrypted_response_enc_values_supported"
  }

  /// Initializes a `ClientMetaData` instance with the provided values.
  /// - Parameters:
  ///   - jwks: A JWK set.
  ///   - idTokenSignedResponseAlg: The ID token signed response algorithm.
  ///   - idTokenEncryptedResponseAlg: The ID token encrypted response algorithm.
  ///   - idTokenEncryptedResponseEnc: The ID token encrypted response encryption.
  ///   - subjectSyntaxTypesSupported: The subject syntax types supported.
  ///   - vpFormats: The Verifiable Presentation formats supported.
  ///   - responseEncryptionMethodsSupported: The list of supported response encryption methods.
  public init(
    jwks: String? = nil,
    idTokenSignedResponseAlg: String? = nil,
    idTokenEncryptedResponseAlg: String?,
    idTokenEncryptedResponseEnc: String?,
    subjectSyntaxTypesSupported: [String],
    vpFormats: VpFormatsTO?,
    responseEncryptionMethodsSupported: [String]? = nil
  ) {
    self.jwks = jwks
    self.idTokenSignedResponseAlg = idTokenSignedResponseAlg
    self.idTokenEncryptedResponseAlg = idTokenEncryptedResponseAlg
    self.idTokenEncryptedResponseEnc = idTokenEncryptedResponseEnc
    self.subjectSyntaxTypesSupported = subjectSyntaxTypesSupported
    self.vpFormats = vpFormats
    self.responseEncryptionMethodsSupported = responseEncryptionMethodsSupported
  }

  /// Initializes a `ClientMetaData` instance with the provided JSON object representing metadata.
  /// - Parameter metaData: The JSON object representing the metadata.
  /// - Throws: An error if the required values are missing or invalid in the metadata.
  public init(metaData: JSON) throws {

    let dictionaryObject = metaData.dictionaryObject ?? [:]

    let jwks = metaData["jwks"].dictionaryObject
    self.jwks = jwks?.toJSONString()

    self.idTokenSignedResponseAlg = try? dictionaryObject.getValue(
      for: "id_token_signed_response_alg",
      error: ValidationError.invalidClientMetadata
    )
    self.idTokenEncryptedResponseAlg = try? dictionaryObject.getValue(
      for: "id_token_encrypted_response_alg",
      error: ValidationError.invalidClientMetadata
    )
    self.idTokenEncryptedResponseEnc = try? dictionaryObject.getValue(
      for: "id_token_encrypted_response_enc",
      error: ValidationError.invalidClientMetadata
    )
    self.subjectSyntaxTypesSupported = (try? dictionaryObject.getValue(
      for: "subject_syntax_types_supported",
      error: ValidationError.invalidClientMetadata
    )) ?? []

    let vpFormatsDictionary: JSON = JSON(dictionaryObject)[Self.vpFormats]
    if let formats = try? vpFormatsDictionary.decoded(as: VpFormatsTO.self) {
      self.vpFormats = formats
    } else {
      self.vpFormats = nil
    }
    
    self.responseEncryptionMethodsSupported = try? dictionaryObject.getValue(
      for: RESPONSE_ENCRYPTION_METHODS_SUPPORTED,
      error: ValidationError.invalidClientMetadata
    )
  }

  /// Initializes a `ClientMetaData` instance with the provided metadata string.
  /// - Parameter metaDataString: The string representing the metadata.
  /// - Throws: An error if the metadata string is invalid or cannot be converted to a dictionary.
  public init(metaDataString: String) throws {
    guard let metaData = try metaDataString.convertToDictionary() else {
      throw ValidationError.invalidClientMetadata
    }

    let jwks = metaData["jwks"] as? [String: Any]
    self.jwks = jwks?.toJSONString()

    self.idTokenSignedResponseAlg = try? metaData.getValue(
      for: "id_token_signed_response_alg",
      error: ValidationError.invalidClientMetadata
    )
    self.idTokenEncryptedResponseAlg = try? metaData.getValue(
      for: "id_token_encrypted_response_alg",
      error: ValidationError.invalidClientMetadata
    )
    self.idTokenEncryptedResponseEnc = try? metaData.getValue(
      for: "id_token_encrypted_response_enc",
      error: ValidationError.invalidClientMetadata
    )

    self.subjectSyntaxTypesSupported = (try? metaData.getValue(
      for: "subject_syntax_types_supported",
      error: ValidationError.invalidClientMetadata
    )) ?? []

    let vpFormatsDictionary: JSON = JSON(metaData)[Self.vpFormats]
    if let formats = try? vpFormatsDictionary.decoded(as: VpFormatsTO.self) {
      self.vpFormats = formats
    } else {
      self.vpFormats = nil
    }
    
    self.responseEncryptionMethodsSupported = try? metaData.getValue(
      for: RESPONSE_ENCRYPTION_METHODS_SUPPORTED,
      error: ValidationError.invalidClientMetadata
    )
  }
}

public extension ClientMetaData {

  struct Validated: Equatable, Sendable {
    public let jwkSet: WebKeySet?
    public let idTokenJWSAlg: JWSAlgorithm?
    public let idTokenJWEAlg: JWEAlgorithm?
    public let idTokenJWEEnc: JOSEEncryptionMethod?
    public let subjectSyntaxTypesSupported: [SubjectSyntaxType]
    public let authorizationSignedResponseAlg: JWSAlgorithm?
    public let authorizationEncryptedResponseAlg: JWEAlgorithm?
    public let authorizationEncryptedResponseEnc: JOSEEncryptionMethod?
    public let vpFormats: VpFormats
    public let responseEncryptionSpecification: ResponseEncryptionSpecification?

    public init(
      jwkSet: WebKeySet? = nil,
      idTokenJWSAlg: JWSAlgorithm? = nil,
      idTokenJWEAlg: JWEAlgorithm? = nil,
      idTokenJWEEnc: JOSEEncryptionMethod? = nil,
      subjectSyntaxTypesSupported: [SubjectSyntaxType],
      authorizationSignedResponseAlg: JWSAlgorithm? = nil,
      authorizationEncryptedResponseAlg: JWEAlgorithm? = nil,
      authorizationEncryptedResponseEnc: JOSEEncryptionMethod? = nil,
      vpFormats: VpFormats,
      responseEncryptionSpecification: ResponseEncryptionSpecification? = nil
    ) {
      self.jwkSet = jwkSet
      self.idTokenJWSAlg = idTokenJWSAlg
      self.idTokenJWEAlg = idTokenJWEAlg
      self.idTokenJWEEnc = idTokenJWEEnc
      self.subjectSyntaxTypesSupported = subjectSyntaxTypesSupported
      self.authorizationSignedResponseAlg = authorizationSignedResponseAlg
      self.authorizationEncryptedResponseAlg = authorizationEncryptedResponseAlg
      self.authorizationEncryptedResponseEnc = authorizationEncryptedResponseEnc
      self.vpFormats = vpFormats
      self.responseEncryptionSpecification = responseEncryptionSpecification
    }
  }
}

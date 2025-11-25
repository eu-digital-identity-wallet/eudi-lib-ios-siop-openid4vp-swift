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

  static let vpFormatsSupported = "vp_formats_supported"

  public let jwks: String?
  public let vpFormatsSupported: VpFormatsSupportedTO?
  public let responseEncryptionMethodsSupported: [String]?

  /// Coding keys for encoding and decoding the structure.
  enum CodingKeys: String, CodingKey {
    case jwks = "jwks"
    case vpFormatsSupported = "vp_formats_supported"
    case responseEncryptionMethodsSupported = "encrypted_response_enc_values_supported"
  }

  /// Initializes a `ClientMetaData` instance with the provided values.
  /// - Parameters:
  ///   - jwks: A JWK set.
  ///   - vpFormats: The Verifiable Presentation formats supported.
  ///   - responseEncryptionMethodsSupported: The list of supported response encryption methods.
  public init(
    jwks: String? = nil,
    vpFormatsSupported: VpFormatsSupportedTO?,
    responseEncryptionMethodsSupported: [String]? = nil
  ) {
    self.jwks = jwks
    self.vpFormatsSupported = vpFormatsSupported
    self.responseEncryptionMethodsSupported = responseEncryptionMethodsSupported
  }

  /// Initializes a `ClientMetaData` instance with the provided JSON object representing metadata.
  /// - Parameter metaData: The JSON object representing the metadata.
  /// - Throws: An error if the required values are missing or invalid in the metadata.
  public init(metaData: JSON) throws {

    let dictionaryObject = metaData.dictionaryObject ?? [:]

    let jwks = metaData["jwks"].dictionaryObject
    self.jwks = jwks?.toJSONString()

    let vpFormatsDictionary: JSON = JSON(dictionaryObject)[Self.vpFormatsSupported]
    if let formats = try? vpFormatsDictionary.decoded(as: VpFormatsSupportedTO.self) {
      self.vpFormatsSupported = formats
    } else {
      self.vpFormatsSupported = nil
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

    let vpFormatsDictionary: JSON = JSON(metaData)[Self.vpFormatsSupported]
    if let formats = try? vpFormatsDictionary.decoded(as: VpFormatsSupportedTO.self) {
      self.vpFormatsSupported = formats
    } else {
      self.vpFormatsSupported = nil
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
    public let authorizationSignedResponseAlg: JWSAlgorithm?
    public let authorizationEncryptedResponseAlg: JWEAlgorithm?
    public let authorizationEncryptedResponseEnc: JOSEEncryptionMethod?
    public let vpFormatsSupported: VpFormatsSupported
    public let responseEncryptionSpecification: ResponseEncryptionSpecification?

    public init(
      jwkSet: WebKeySet? = nil,
      authorizationSignedResponseAlg: JWSAlgorithm? = nil,
      authorizationEncryptedResponseAlg: JWEAlgorithm? = nil,
      authorizationEncryptedResponseEnc: JOSEEncryptionMethod? = nil,
      vpFormatsSupported: VpFormatsSupported,
      responseEncryptionSpecification: ResponseEncryptionSpecification? = nil
    ) {
      self.jwkSet = jwkSet
      self.authorizationSignedResponseAlg = authorizationSignedResponseAlg
      self.authorizationEncryptedResponseAlg = authorizationEncryptedResponseAlg
      self.authorizationEncryptedResponseEnc = authorizationEncryptedResponseEnc
      self.vpFormatsSupported = vpFormatsSupported
      self.responseEncryptionSpecification = responseEncryptionSpecification
    }
  }
}

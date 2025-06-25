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
@preconcurrency import Foundation
@preconcurrency import JOSESwift // Assuming JWK is from JOSESwift

/// Represents the wallet's support level for JARM (JWT Secured Authorization Response Mode).
public indirect enum JARMConfiguration: Sendable {

  /// The wallet supports only signed authorization responses.
  case signing

  /// The wallet supports only encrypted authorization responses.
  case encryption(Encryption)

  /// The wallet supports both signing and encryption.
  case signingAndEncryption(
    signing: JARMConfiguration,
    encryption: JARMConfiguration
  )

  /// The wallet does not configure JARM responses.
  case noConfiguration

  // MARK: - Subtypes for Composition

  public struct Encryption: Sendable {
    public let supportedAlgorithms: [JWEAlgorithm]
    public let supportedMethods: [EncryptionMethod]

    public init(supportedAlgorithms: [JWEAlgorithm], supportedMethods: [EncryptionMethod]) throws {
      if supportedAlgorithms.isEmpty {
        throw ValidationError.validationError(
          "At least one encryption algorithm must be provided"
        )
      }
      if supportedMethods.isEmpty {
        throw ValidationError.validationError(
          "At least one encryption method must be provided"
        )
      }
      
      self.supportedAlgorithms = supportedAlgorithms
      self.supportedMethods = supportedMethods
    }
  }

  // MARK: - Helper Accessors

  public var signingConfig: JARMConfiguration? {
    switch self {
    case .signing:
      return self
    case .signingAndEncryption(let signing, _):
      return signing
    default:
      return nil
    }
  }

  public var encryptionConfig: JARMConfiguration? {
    switch self {
    case .encryption:
      return self
    case .signingAndEncryption(_, let encryption):
      return encryption
    default:
      return nil
    }
  }
  
  public static func `default`() -> JARMConfiguration {
    try! .signingAndEncryption(
      signing: .signing,
      encryption: .encryption(
        .init(
          supportedAlgorithms: [
            .init(.RSA1_5),
            .init(.RSA_OAEP),
            .init(.RSA_OAEP_256),
            .init(.RSA_OAEP_384),
            .init(.RSA_OAEP_512),
            .init(.A128KW),
            .init(.A192KW),
            .init(.A256KW),
            .init(.DIR),
            .init(.ECDH_ES),
            .init(.ECDH_ES_A128KW),
            .init(.ECDH_ES_A192KW),
            .init(.ECDH_ES_A256KW),
            .init(.ECDH_1PU),
            .init(.ECDH_1PU_A128KW),
            .init(.ECDH_1PU_A192KW),
            .init(.ECDH_1PU_A256KW),
            .init(.A128GCMKW),
            .init(.A192GCMKW),
            .init(.A256GCMKW),
            .init(.PBES2_HS256_A128KW),
            .init(.PBES2_HS384_A192KW),
            .init(.PBES2_HS512_A256KW),
          ],
          supportedMethods: [
            .init(.A128CBC_HS256),
            .init(.A128CBC_HS256),
            .init(.A192CBC_HS384),
            .init(.A256CBC_HS512),
            .init(.A128GCM),
            .init(.A192GCM),
            .init(.A256GCM),
            .init(.XC20P)
          ]
        )
      )
    )
  }
}

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
public indirect enum JarmConfiguration: Sendable {
  
  /// The wallet supports only signed authorization responses.
  case signing(
    keyPair: SigningKeyPair
  )
  
  /// The wallet supports only encrypted authorization responses.
  case encryption(
    supportedAlgorithms: [JWEAlgorithm],
    supportedMethods: [EncryptionMethod]
  )
  
  /// The wallet supports both signing and encryption.
  case signingAndEncryption(
    signing: JarmConfiguration,
    encryption: JarmConfiguration
  )
  
  /// The wallet does not support JARM responses.
  case notSupported
  
  // MARK: - Subtypes for Composition
  
  public struct Signing {
    public let keyPair: SigningKeyPair
    public let ttl: TimeInterval
    
    public init(keyPair: SigningKeyPair, ttl: TimeInterval = 600) {
      self.keyPair = keyPair
      self.ttl = ttl
    }
  }
  
  public struct Encryption {
    public let supportedAlgorithms: [JWEAlgorithm]
    public let supportedMethods: [EncryptionMethod]
    
    public init(supportedAlgorithms: [JWEAlgorithm], supportedMethods: [EncryptionMethod]) {
      precondition(!supportedAlgorithms.isEmpty, "At least one encryption algorithm must be provided")
      precondition(!supportedMethods.isEmpty, "At least one encryption method must be provided")
      self.supportedAlgorithms = supportedAlgorithms
      self.supportedMethods = supportedMethods
    }
  }
  
  public struct SigningKeyPair : Sendable{
    public let privateKey: SecKey
    public let webKeySet: WebKeySet
    
    public init(privateKey: SecKey, webKeySet: WebKeySet) {
      self.privateKey = privateKey
      self.webKeySet = webKeySet
    }
  }
  
  // MARK: - Helper Accessors
  
  public var signingConfig: JarmConfiguration? {
    switch self {
    case .signing(let keyPair):
      return self
    case .signingAndEncryption(let signing, _):
      return signing
    default:
      return nil
    }
  }
  
  public var encryptionConfig: JarmConfiguration? {
    switch self {
    case .encryption(let algorithms, let methods):
      return self
    case .signingAndEncryption(_, let encryption):
      return encryption
    default:
      return nil
    }
  }
}



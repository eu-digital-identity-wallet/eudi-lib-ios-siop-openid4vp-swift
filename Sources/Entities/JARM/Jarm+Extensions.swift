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
import JOSESwift

import JOSESwift

public extension SiopOpenId4VPConfiguration {
  
  /// Computes the JARM requirement for the given validated client metadata.
  func jarmRequirement(
    validated clientMetadata: ClientMetaData.Validated?
  ) -> JarmRequirement? {
    guard let clientMetadata = clientMetadata else {
      return nil
    }
    return jarmConfiguration.jarmRequirement(
      validated: clientMetadata
    )
  }
}

public extension JarmConfiguration {
  
  /// Computes a `JarmRequirement` from this configuration and the client's validated metadata.
  func jarmRequirement(
    validated clientMetadata: ClientMetaData.Validated
  ) -> JarmRequirement? {
    switch self {
    case .signing(_):
      guard let alg = clientMetadata.authorizationSignedResponseAlg else {
        return nil
      }
      return .signed(responseSigningAlg: alg)
      
    case .encryption(_, _):
      guard
        let alg = clientMetadata.authorizationEncryptedResponseAlg,
        let enc = clientMetadata.authorizationEncryptedResponseEnc,
        let key = clientMetadata.jwkSet
      else {
        return nil
      }
      return .encrypted(
        responseEncryptionAlg: alg,
        responseEncryptionEnc: EncryptionMethod(name: enc.name),
        clientKey: key
      )
      
    case .signingAndEncryption(let signingConfig, let encryptionConfig):
      let signingRequirement = signingConfig.jarmRequirement(validated: clientMetadata)
      let encryptionRequirement = encryptionConfig.jarmRequirement(validated: clientMetadata)
      
      switch (signingRequirement, encryptionRequirement) {
      case let (.some(signed), .some(encrypted)):
        return .signedAndEncrypted(signed: signed, encrypted: encrypted)
      case let (.some(signed), nil):
        return signed
      case let (nil, .some(encrypted)):
        return encrypted
      default:
        return nil
      }
      
    case .notSupported:
      return .noRequirement
    }
  }
}

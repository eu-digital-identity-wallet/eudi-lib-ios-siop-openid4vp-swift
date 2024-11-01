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

public indirect enum JarmOption {
  case signedResponse(
    responseSigningAlg: JWSAlgorithm,
    signingKeySet: WebKeySet,
    signingKey: SecKey
  )
  case encryptedResponse(
    responseSigningAlg: JWEAlgorithm,
    responseEncryptionEnc: JOSEEncryptionMethod,
    signingKeySet: WebKeySet
  )
  case signedAndEncryptedResponse(signed: JarmOption, encrypted: JarmOption)
}

public extension JarmOption {
  init(
    clientMetaData: ClientMetaData.Validated,
    walletOpenId4VPConfig: SiopOpenId4VPConfiguration
  ) throws {
    var signed: JarmOption?
    if let signingAlgorithm = clientMetaData.authorizationSignedResponseAlg {
      signed = .signedResponse(
        responseSigningAlg: signingAlgorithm,
        signingKeySet: walletOpenId4VPConfig.signingKeySet,
        signingKey: walletOpenId4VPConfig.signingKey
      )
    }

    var encrypted: JarmOption?
    if let jweAlg = clientMetaData.authorizationEncryptedResponseAlg,
       let authorizationEncryptedResponseEnc = clientMetaData.authorizationEncryptedResponseEnc,
       let jwkSet = clientMetaData.jwkSet {

      encrypted = .encryptedResponse(
        responseSigningAlg: jweAlg,
        responseEncryptionEnc: authorizationEncryptedResponseEnc,
        signingKeySet: jwkSet
      )
    }

    if let signed = signed, let encrypted = encrypted {
      self = .signedAndEncryptedResponse(signed: signed, encrypted: encrypted)
      return
    } else if let signed = signed {
      self = signed
      return
    } else if let encrypted = encrypted {
      self = encrypted
      return
    }

    throw ValidatedAuthorizationError.invalidJarmOption
  }
}

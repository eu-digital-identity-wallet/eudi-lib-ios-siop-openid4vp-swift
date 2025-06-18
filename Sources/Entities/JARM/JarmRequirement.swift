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

//
//
//  Represents the client's requirements for JWT Secured Authorization Response Mode (JARM)
//  as defined in OpenID Connect. This enum models whether the response should be signed,
//  encrypted, or both (signed then encrypted).
//
//  - `signed`:     Requires a signed JARM response using the specified `JWSAlgorithm`.
//  - `encrypted`:  Requires an encrypted JARM response using a specified `JWEAlgorithm`,
//                  `EncryptionMethod`, and the client's public key (`JWK`).
//  - `signedAndEncrypted`: Combines both signing and encryption. The response is first signed,
//                          then encrypted using the provided sub-requirements.
//
//  This enum is `indirect` to allow recursive nesting in `signedAndEncrypted`.
//
public indirect enum JarmRequirement: Sendable {
  
  /// Client requires JARM signed response using the `responseSigningAlg` signing algorithm
  case signed(responseSigningAlg: JWSAlgorithm)
  
  /// Client requires JARM encrypted response using the given encryption parameters
  case encrypted(
    responseEncryptionAlg: JWEAlgorithm,
    responseEncryptionEnc: EncryptionMethod,
    clientKey: WebKeySet.Key
  )
  
  /// Client requires JARM signed and (then) encrypted response
  case signedAndEncrypted(
    signed: JarmRequirement,
    encrypted: JarmRequirement
  )
}


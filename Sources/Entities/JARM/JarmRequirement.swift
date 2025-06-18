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

public indirect enum JarmRequirement {
  
  /// Client requires JARM signed response using the `responseSigningAlg` signing algorithm
  case signed(responseSigningAlg: JWSAlgorithm)
  
  /// Client requires JARM encrypted response using the given encryption parameters
  case encrypted(
    responseEncryptionAlg: JWEAlgorithm,
    responseEncryptionEnc: EncryptionMethod,
    clientKey: JWK
  )
  
  /// Client requires JARM signed and (then) encrypted response
  case signedAndEncrypted(
    signed: JarmRequirement,
    encrypted: JarmRequirement
  )
}


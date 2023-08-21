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

public enum EncryptionMethod: String {
  case a128Cbc_hs256 = "A128CBC-HS256"
  case a192Cbc_hs384 = "A192CBC-HS384"
  case a256Cbc_hs512 = "A256CBC-HS512"
  case a128gcm = "A128GCM"
  case a192gcm = "A192GCM"
  case a256gcm = "A256GCM"
  case xc20p = "XC20P"
}

public extension ContentEncryptionAlgorithm {
  init?(encryptionMethod: EncryptionMethod) {
    self.init(rawValue: encryptionMethod.rawValue)
  }
}

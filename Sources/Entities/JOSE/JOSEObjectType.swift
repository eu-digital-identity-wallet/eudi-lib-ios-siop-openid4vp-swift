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

public enum JOSEObjectType: String {

  case JOSE = "JOSE"
  case JOSE_JSON = "JOSE+JSON"
  case JWT = "JWT"
  case REQ_JWT = "oauth-authz-req+jwt"
  case VERIFIER_ATTESTATION = "verifier-attestation+jwt"

  public var type: String {
    return self.rawValue
  }
}

public extension JOSEObjectType {
  static func parse(_ type: String) throws -> JOSEObjectType {
    guard let objectType = JOSEObjectType(rawValue: type) else {
      throw JOSEError.invalidObjectType
    }
    return objectType
  }
}

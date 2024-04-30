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
import X509

public enum Client {
  case preRegistered(
    clientId: String,
    legalName: String
  )
  case redirectUri(clientId: URL)
  case x509SanDns(
    clientId: String,
    certificate: Certificate
  )
  case x509SanUri(
    clientId: URL,
    certificate: Certificate
  )

   /**
    * The id of the client.
    */
  var id: String {
    switch self {
    case .preRegistered(let clientId, _):
      return clientId
    case .redirectUri(let clientId):
      return clientId.absoluteString
    case .x509SanDns(let clientId, _):
      return clientId
    case .x509SanUri(let clientId, _):
      return clientId.absoluteString
    }
  }
  
  var legalName: String? {
    switch self {
    case .preRegistered(_, let legalName):
      return legalName
    case .redirectUri:
      return nil
    case .x509SanDns(_, let certificate):
      return certificate.leganame
    case .x509SanUri(_, let certificate):
      return certificate.leganame
    }
  }
}

extension Certificate {
  var leganame: String {
    ""
  }
}

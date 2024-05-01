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
import SwiftASN1

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
    clientId: String,
    certificate: Certificate
  )

   /**
    * The id of the client.
    */
  public var id: String {
    switch self {
    case .preRegistered(let clientId, _):
      return clientId
    case .redirectUri(let clientId):
      return clientId.absoluteString
    case .x509SanDns(let clientId, _):
      return clientId
    case .x509SanUri(let clientId, _):
      return clientId
    }
  }
  
  public var legalName: String? {
    switch self {
    case .preRegistered(_, let legalName):
      return legalName
    case .redirectUri:
      return nil
    case .x509SanDns(_, let certificate):
      return certificate.legaName
    case .x509SanUri(_, let certificate):
      return certificate.legaName
    }
  }
}

public extension Certificate {
  var legaName: String {
    let a = GeneralName.directoryName(issuer)
    switch a {
    case .directoryName(let name):
      guard let organizationName = name.lazy.filter({ name in
        name.contains { attribute in
          attribute.type == ASN1ObjectIdentifier.RDNAttributeType.organizationName
        }
      }).first else {
        return ""
      }
      return String(describing: organizationName.description).components(separatedBy: "=").last ?? ""
    default: return ""
    }
  }
}


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
@preconcurrency import SwiftyJSON

public struct VerifierAttestation: Codable, Sendable, Equatable {

  public let format: String
  public let data: JSON
  public let credentialIds: [QueryId]?

  public init(
    format: String,
    data: JSON,
    credentialIds: [QueryId]? = nil
  ) {
    self.format = format
    self.data = data
    self.credentialIds = credentialIds
  }

  public static func from(json: JSON) throws -> VerifierAttestation {
      guard let format = json["format"].string else {
        throw ValidationError.invalidVerifierAttestationFormat
      }

      let data = json["data"]

      var credentialIds: [QueryId]? = nil
      if let idArray = json["credentialIds"].array {
        credentialIds = try idArray.compactMap {
          try QueryId(value: $0.stringValue) }
      }

      return VerifierAttestation(format: format, data: data, credentialIds: credentialIds)
  }
}


public extension VerifierAttestation {
  
  static func validatedVerifierAttestations(
    _ attestations: [VerifierAttestation]?,
    presentationQuery: PresentationQuery
  ) throws -> [VerifierAttestation]? {
    
    guard let attestations else { return nil }
    switch presentationQuery {
    case .byDigitalCredentialsQuery(let dcql):
      let validIds = Set(dcql.credentials.map { $0.id })
      
      for attestation in attestations {
        if let ids = attestation.credentialIds {
          for id in ids {
            guard validIds.contains(id) else {
              throw ValidationError.invalidVerifierAttestationCredentialIds
            }
          }
        }
      }
      
      return attestations
    case .byPresentationDefinition(_):
      return nil
    }
  }
}


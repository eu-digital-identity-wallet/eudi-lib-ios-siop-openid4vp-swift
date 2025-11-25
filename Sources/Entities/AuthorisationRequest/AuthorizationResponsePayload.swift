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

/// An enumeration representing different types of authorization response payloads.
public enum AuthorizationResponsePayload: Encodable, Sendable {

  /// An OpenID Connect 4 Verifiable Presentation authorization response payload.
  case openId4VPAuthorizationResponse(
    vpContent: VpContent,
    state: String,
    nonce: String,
    clientId: VerifierId,
    encryptionParameters: EncryptionParameters?
  )

  /// A failure response payload.
  case failure

  /// An invalid request response payload.
  case invalidRequest(
    error: AuthorizationRequestError,
    nonce: String?,
    state: String?,
    clientId: VerifierId?
  )

  /// A response payload indicating no consensus response data.
  case noConsensusResponseData(state: String, error: String)

  /// Coding keys for encoding the enumeration.
  enum CodingKeys: String, CodingKey {
    case openId4VPAuthorizationResponse
    case failure
    case invalidRequest
    case noConsensusResponseData
    case state
    case nonce
    case error
    case vpToken = "vp_token"
    case presentationSubmission = "presentation_submission"
  }

  var encryptionParameters: EncryptionParameters? {
    switch self {
    case .openId4VPAuthorizationResponse(_, _, _, _, let encryptionParameters):
      return encryptionParameters
    default: return nil
    }
  }

  var apu: String? {
    switch self.encryptionParameters {
    case .apu(let apu):
      return apu
    case .none:
      return nil
    }
  }

  var nonce: String {
    switch self {
    case .openId4VPAuthorizationResponse(_, _, let nonce, _, _):
      nonce
    default:
      ""
    }
  }

  /// Encodes the enumeration using the given encoder.
  public func encode(to encoder: Encoder) throws {
     var container = encoder.container(keyedBy: CodingKeys.self)

     switch self {
     case .openId4VPAuthorizationResponse(
      let vpContent,
      let state,
      _,
      _,
      _
     ):
       switch vpContent {
       case .dcql(let verifiablePresentations):
         try container.encode(state, forKey: .state)
         try container.encode(VpContent .encodeDCQLQuery(verifiablePresentations), forKey: .vpToken)
       }
     case .noConsensusResponseData(let state, let message):
       try container.encode(state, forKey: .state)
       try container.encode(message, forKey: .error)
     default: break
     }
   }
}

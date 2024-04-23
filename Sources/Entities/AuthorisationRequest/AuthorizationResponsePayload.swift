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
public enum AuthorizationResponsePayload: Encodable {
  
  /// An SIOP authentication response payload.
  case siopAuthenticationResponse(
    idToken: JWTString,
    state: String,
    nonce: String
  )

  /// An OpenID Connect 4 Verifiable Presentation authorization response payload.
  case openId4VPAuthorizationResponse(
    vpToken: VpToken,
    verifiableCredential: [JWTString],
    presentationSubmission: PresentationSubmission,
    state: String,
    nonce: String
  )

  /// An SIOP OpenID Connect 4 Verifiable Presentation authentication response payload.
  case siopOpenId4VPAuthenticationResponse(
    idToken: JWTString,
    verifiableCredential: [JWTString],
    presentationSubmission: PresentationSubmission,
    state: String,
    nonce: String
  )

  /// A failure response payload.
  case failure

  /// An invalid request response payload.
  case invalidRequest(error: AuthorizationError, state: String)

  /// A response payload indicating no consensus response data.
  case noConsensusResponseData(state: String, error: String)

  /// Coding keys for encoding the enumeration.
  enum CodingKeys: String, CodingKey {
    case siopAuthenticationResponse
    case openId4VPAuthorizationResponse
    case siopOpenId4VPAuthenticationResponse
    case failure
    case invalidRequest
    case noConsensusResponseData
    case idToken = "id_token"
    case state
    case nonce
    case error
    case vpToken = "vp_token"
    case presentationSubmission = "presentation_submission"
  }

  var vpTokenValue: String? {
    switch self {
    case .openId4VPAuthorizationResponse(let vpToken, _, _, _, _):
      vpToken.value
    default: nil
    }
  }
  
  var vpTokenApu: String? {
    switch self {
    case .openId4VPAuthorizationResponse(let vpToken, _, _, _, _):
      vpToken.apu
    default: nil
    }
  }
  
  var nonce: String {
    switch self {
    case .siopAuthenticationResponse(_, _, let nonce):
      nonce
    case .openId4VPAuthorizationResponse(_, _, _, _, let nonce):
      nonce
    case .siopOpenId4VPAuthenticationResponse(_, _, _, _, let nonce):
      nonce
    default:
      ""
    }
  }
  
  /// Encodes the enumeration using the given encoder.
  public func encode(to encoder: Encoder) throws {
     var container = encoder.container(keyedBy: CodingKeys.self)

     switch self {
     case .siopAuthenticationResponse(let idToken, let state, let nonce):
       try container.encode(state, forKey: .state)
       try container.encode(idToken, forKey: .idToken)
     case .openId4VPAuthorizationResponse(
      let vpToken,
      _,
      let presentationSubmission,
      let state,
      let nonce
     ):
       try container.encode(presentationSubmission, forKey: .presentationSubmission)
       try container.encode(vpToken.value, forKey: .vpToken)
       try container.encode(state, forKey: .state)
     case .noConsensusResponseData(let state, let message):
       try container.encode(state, forKey: .state)
       try container.encode(message, forKey: .error)
     default: break
     }
   }
}

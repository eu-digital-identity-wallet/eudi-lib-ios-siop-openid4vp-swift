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

/// An enumeration representing different types of authorization responses.
public enum AuthorizationResponse: Sendable {
  /// A direct POST authorization response.
  case directPost(url: URL, data: AuthorizationResponsePayload)

  /// A direct POST JWT authorization response.
  case directPostJwt(
    url: URL,
    data: AuthorizationResponsePayload,
    responseEncryptionSpecification: ResponseEncryptionSpecification
  )

  /// A query authorization response.
  case query(url: URL, data: AuthorizationResponsePayload)

  /// A query JWT authorization response.
  case queryJwt(
    url: URL,
    data: AuthorizationResponsePayload,
    responseEncryptionSpecification: ResponseEncryptionSpecification
  )

  /// A fragment authorization response.
  case fragment(url: URL, data: AuthorizationResponsePayload)

  /// A fragment JWT authorization response.
  case fragmentJwt(
    url: URL,
    data: AuthorizationResponsePayload,
    responseEncryptionSpecification: ResponseEncryptionSpecification
  )

  case invalidRequest(
    error: AuthorizationRequestError,
    nonce: String?,
    state: String?,
    clientId: VerifierId?
  )
}

/// An extension providing additional functionality to the `AuthorizationResponse` enumeration.
public extension AuthorizationResponse {
  /// Initializes an `AuthorizationResponse` based on the resolved request and consent.
  /// - Parameters:
  ///   - resolvedRequest: The resolved Verifiable Presentation request data.
  ///   - consent: The client consent.
  init(
    resolvedRequest: ResolvedRequestData,
    consent: ClientConsent,
    walletOpenId4VPConfig: OpenId4VPConfiguration? = nil,
    encryptionParameters: EncryptionParameters? = nil
  ) throws {
    switch consent {
    case .vpToken(let vpContent):
      let request = resolvedRequest.request
      let payload: AuthorizationResponsePayload = .openId4VPAuthorizationResponse(
        vpContent: vpContent,
        state: request.state ?? "",
        nonce: request.nonce,
        clientId: resolvedRequest.client.id,
        encryptionParameters: encryptionParameters
      )
      self = try .buildAuthorizationResponse(
        responseMode: request.responseMode,
        payload: payload,
        clientMetaData: request.clientMetaData,
        walletOpenId4VPConfig: walletOpenId4VPConfig,
        responseEncryptionSpecification: request.responseEncryptionSpecification
      )
    case .negative(let error):
      let request = resolvedRequest.request
      let payload: AuthorizationResponsePayload = .noConsensusResponseData(
        state: try request.state ?? { throw AuthorizationError.invalidState }(),
        error: error
      )
      self = try .buildAuthorizationResponse(
        responseMode: request.responseMode,
        payload: payload,
        clientMetaData: request.clientMetaData,
        walletOpenId4VPConfig: walletOpenId4VPConfig,
        responseEncryptionSpecification: request.responseEncryptionSpecification
      )
    }
  }
}

/// A private extension providing utility functions for the `AuthorizationResponse` enumeration.
private extension AuthorizationResponse {
  /// Builds an authorization response based on the response mode and payload.
  /// - Parameters:
  ///   - responseMode: The response mode.
  ///   - payload: The authorization response payload.
  /// - Returns: An `AuthorizationResponse` instance.
  static func buildAuthorizationResponse(
    responseMode: ResponseMode?,
    payload: AuthorizationResponsePayload,
    clientMetaData: ClientMetaData.Validated?,
    walletOpenId4VPConfig: OpenId4VPConfiguration?,
    responseEncryptionSpecification: ResponseEncryptionSpecification?
  ) throws -> AuthorizationResponse {
    guard let responseMode = responseMode else {
      throw AuthorizationError.invalidResponseMode
    }
    
    switch responseMode {
    case .directPost(let responseURI):
      return .directPost(
        url: responseURI,
        data: payload
      )
    case .directPostJWT(let responseURI):
      guard let responseEncryptionSpecification = responseEncryptionSpecification else {
        throw ValidationError.invalidJarmRequirement
      }
      return .directPostJwt(
        url: responseURI,
        data: payload,
        responseEncryptionSpecification: responseEncryptionSpecification
      )
    case .query(let responseURI):
      return .query(
        url: responseURI,
        data: payload
      )
    case .fragment(let responseURI):
      return .fragment(
        url: responseURI,
        data: payload
      )
    case .none:
      throw AuthorizationError.invalidResponseMode
    }
  }
}

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
import PresentationExchange

/// An enumeration representing different types of authorization requests.
public enum AuthorizationRequest {
  /// A not secured authorization request.
  case notSecured(data: ResolvedRequestData)

  /// A JWT authorization request.
  case jwt(request: ResolvedRequestData)
}

/// An extension providing an initializer for the `AuthorizationRequest` enumeration.
public extension AuthorizationRequest {
  /// Initializes an `AuthorizationRequest` using the provided authorization request data.
  /// - Parameters:
  ///   - authorizationRequestData: The authorization request data to process.
  init(authorizationRequestData: AuthorisationRequestObject?) async throws {
    guard let authorizationRequestData = authorizationRequestData else {
      throw ValidatedAuthorizationError.noAuthorizationData
    }

    guard !authorizationRequestData.hasConflicts else {
      throw ValidatedAuthorizationError.conflictingData
    }

    if let request = authorizationRequestData.request {
      let validatedAuthorizationRequestData = try ValidatedSiopOpenId4VPRequest(request: request)

      let resolvedSiopOpenId4VPRequestData = try await ResolvedRequestData(
        clientMetaDataResolver: ClientMetaDataResolver(),
        presentationDefinitionResolver: PresentationDefinitionResolver(),
        validatedAuthorizationRequest: validatedAuthorizationRequestData
      )
      self = .jwt(request: resolvedSiopOpenId4VPRequestData)
    } else if let requestUri = authorizationRequestData.requestUri {
      let validatedAuthorizationRequestData = try await ValidatedSiopOpenId4VPRequest(requestUri: requestUri, clientId: authorizationRequestData.clientId)

      let resolvedSiopOpenId4VPRequestData = try await ResolvedRequestData(
        clientMetaDataResolver: ClientMetaDataResolver(),
        presentationDefinitionResolver: PresentationDefinitionResolver(),
        validatedAuthorizationRequest: validatedAuthorizationRequestData
      )
      self = .jwt(request: resolvedSiopOpenId4VPRequestData)
    } else {
      let validatedAuthorizationRequestData = try await ValidatedSiopOpenId4VPRequest(
        authorizationRequestData: authorizationRequestData
      )

      let resolvedSiopOpenId4VPRequestData = try await ResolvedRequestData(
        clientMetaDataResolver: ClientMetaDataResolver(),
        presentationDefinitionResolver: PresentationDefinitionResolver(),
        validatedAuthorizationRequest: validatedAuthorizationRequestData
      )

      self = .notSecured(data: resolvedSiopOpenId4VPRequestData)
    }
  }
}

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

public protocol AuthorizationRequestResolving: Sendable {
  func authorize(
    walletConfiguration: SiopOpenId4VPConfiguration,
    unvalidatedRequest: UnvalidatedRequest
  ) async throws -> AuthorizationRequest
}

public actor AuthorizationRequestResolver: AuthorizationRequestResolving {
  
  public init() {}
  
  public func authorize(
    walletConfiguration: SiopOpenId4VPConfiguration,
    unvalidatedRequest: UnvalidatedRequest
  ) async throws -> AuthorizationRequest {
    
    let clientMetaDataValidator: ClientMetaDataValidator = .init()
    let clientAuthenticator: ClientAuthenticator = .init(
      config: walletConfiguration
    )
    let requestAuthenticator: RequestAuthenticator = .init(
      config: walletConfiguration,
      clientAuthenticator: clientAuthenticator
    )
    
    let fetchedRequest = try await fetchRequest(
      config: walletConfiguration,
      unvalidatedRequest: unvalidatedRequest
    )
    
    let authorizedRequest = try await authenticateRequest(
      clientAuthenticator: clientAuthenticator,
      requestAuthenticator: requestAuthenticator,
      config: walletConfiguration,
      fetchedRequest: fetchedRequest
    )
    
    guard let clientMetaData = authorizedRequest.requestObject.clientMetaData else {
      throw ValidationError.invalidClientMetadata
    }
    
    let validatedClientMetaData = try await validateClientMetaData(
      validator: clientMetaDataValidator,
      clientMetaData: clientMetaData
    )
    
    guard let validatedClientMetaData = validatedClientMetaData else {
      throw ValidationError.invalidClientMetadata
    }
    
    guard
      let unvalidatedResponseType = authorizedRequest.requestObject.responseType,
      let responseType = ResponseType(rawValue: unvalidatedResponseType)
    else {
      throw ValidationError.missingResponseType
    }
    
    guard let nonce = authorizedRequest.requestObject.nonce else {
      throw ValidationError.missingNonce
    }
    
    let validated = try await createValidatedAuthorizationRequest(
      responseType: responseType,
      config: walletConfiguration,
      requestAuthenticator: requestAuthenticator,
      authorizedRequest: authorizedRequest,
      nonce: nonce,
      clientMetaData: validatedClientMetaData
    )
    
    let resolved = try await resolveRequest(
      config: walletConfiguration,
      validatedClientMetaData: validatedClientMetaData,
      validatedAuthorizationRequest: validated
    )
    
    return buildFinalRequest(
      fetchedRequest: fetchedRequest,
      resolved: resolved
    )
  }
  
  private func fetchRequest(
    config: SiopOpenId4VPConfiguration,
    unvalidatedRequest: UnvalidatedRequest
  ) async throws -> FetchedRequest {
    try await RequestFetcher(
      config: config
    ).fetchRequest(request: unvalidatedRequest)
  }
  
  private func authenticateRequest(
    clientAuthenticator: ClientAuthenticator,
    requestAuthenticator: RequestAuthenticator,
    config: SiopOpenId4VPConfiguration,
    fetchedRequest: FetchedRequest
  ) async throws -> AuthenticatedRequest {
    return try await requestAuthenticator.authenticate(
      fetchRequest: fetchedRequest
    )
  }
  
  private func validateClientMetaData(
    validator: ClientMetaDataValidator,
    clientMetaData: String?
  ) async throws -> ClientMetaData.Validated? {
    guard let clientMetaData else {
      throw ValidationError.invalidClientMetadata
    }
    let metaData: ClientMetaData = try .init(metaDataString: clientMetaData)
    return try await validator.validate(clientMetaData: metaData)
  }
  
  private func createValidatedAuthorizationRequest(
    responseType: ResponseType,
    config: SiopOpenId4VPConfiguration,
    requestAuthenticator: RequestAuthenticator,
    authorizedRequest: AuthenticatedRequest,
    nonce: String,
    clientMetaData: ClientMetaData.Validated
  ) async throws -> ValidatedSiopOpenId4VPRequest {
    let clientId = authorizedRequest.client.id.originalClientId
    
    switch responseType {
    case .vpToken:
      return try await requestAuthenticator.createVpToken(
        clientId: clientId,
        client: authorizedRequest.client,
        nonce: nonce,
        requestObject: authorizedRequest.requestObject,
        clientMetaData: clientMetaData
      )
    case .idToken:
      return try await requestAuthenticator.createIdToken(
        clientId: clientId,
        client: authorizedRequest.client,
        nonce: nonce,
        requestObject: authorizedRequest.requestObject
      )
    case .vpAndIdToken:
      return try await requestAuthenticator.createIdVpToken(
        clientId: clientId,
        client: authorizedRequest.client,
        nonce: nonce,
        requestObject: authorizedRequest.requestObject,
        clientMetaData: clientMetaData
      )
    default:
      throw ValidationError.unsupportedResponseType(responseType.rawValue)
    }
  }
  
  private func resolveRequest(
    config: SiopOpenId4VPConfiguration,
    validatedClientMetaData: ClientMetaData.Validated,
    validatedAuthorizationRequest: ValidatedSiopOpenId4VPRequest
  ) async throws -> ResolvedRequestData {
    try await .init(
      vpConfiguration: config.vpConfiguration,
      validatedClientMetaData: validatedClientMetaData,
      presentationDefinitionResolver: PresentationDefinitionResolver(
        fetcher: Fetcher(session: config.session)
      ),
      validatedAuthorizationRequest: validatedAuthorizationRequest
    )
  }
  
  private func buildFinalRequest(
    fetchedRequest: FetchedRequest,
    resolved: ResolvedRequestData
  ) -> AuthorizationRequest {
    switch fetchedRequest {
    case .plain:
      return .notSecured(data: resolved)
    case .jwtSecured:
      return .jwt(request: resolved)
    }
  }
}


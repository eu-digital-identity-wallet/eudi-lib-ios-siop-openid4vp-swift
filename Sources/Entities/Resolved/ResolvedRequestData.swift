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

public enum ResolvedRequestData {
  case idToken(request: IdTokenData)
  case vpToken(request: VpTokenData)
  case idAndVpToken(request: IdAndVpTokenData)
}

public extension ResolvedRequestData {
  /// Initializes a `ResolvedRequestData` instance with the provided parameters.
  ///
  /// - Parameters:
  ///   - clientMetaDataResolver: The resolver for client metadata.
  ///   - presentationDefinitionResolver: The resolver for presentation definition.
  ///   - validatedAuthorizationRequest: The validated SiopOpenId4VPRequest.
  init(
    clientMetaDataResolver: ClientMetaDataResolver,
    presentationDefinitionResolver: PresentationDefinitionResolver,
    validatedAuthorizationRequest: ValidatedSiopOpenId4VPRequest
  ) async throws {
    switch validatedAuthorizationRequest {
    case .idToken(request: let request):
      let clientMetaDataSource = request.clientMetaDataSource
      let clientMetaData = try? await clientMetaDataResolver.resolve(source: clientMetaDataSource).get()

      let validator = ClientMetaDataValidator()
      let validatedClientMetaData = try? await validator.validate(clientMetaData: clientMetaData)
      
      self = .idToken(request: .init(
        idTokenType: request.idTokenType,
        clientMetaData: validatedClientMetaData,
        clientId: request.clientId, 
        client: request.client,
        nonce: request.nonce,
        responseMode: request.responseMode,
        state: request.state,
        scope: request.scope
      ))
    case .vpToken(request: let request):
      let clientMetaDataSource = request.clientMetaDataSource
      let clientMetaData = try? await clientMetaDataResolver.resolve(source: clientMetaDataSource).get()

      let validator = ClientMetaDataValidator()
      let validatedClientMetaData = try? await validator.validate(clientMetaData: clientMetaData)
      
      guard
        let presentationDefinition = try? await presentationDefinitionResolver.resolve(
          source: request.presentationDefinitionSource
        ).get()
      else {
        throw ResolvedAuthorisationError.invalidClientData
      }

      self = .vpToken(request: .init(
        presentationDefinition: presentationDefinition,
        clientMetaData: validatedClientMetaData,
        clientId: request.clientId, 
        client: request.client,
        nonce: request.nonce,
        responseMode: request.responseMode,
        state: request.state
      ))
    case .idAndVpToken(request: let request):
      let clientMetaDataSource = request.clientMetaDataSource
      let clientMetaData = try? await clientMetaDataResolver.resolve(source: clientMetaDataSource).get()

      guard
        let presentationDefinition = try? await presentationDefinitionResolver.resolve(
          source: request.presentationDefinitionSource
        ).get()
      else {
        throw ResolvedAuthorisationError.invalidClientData
      }

      self = .idAndVpToken(request: .init(
        idTokenType: request.idTokenType,
        presentationDefinition: presentationDefinition,
        clientMetaData: clientMetaData,
        clientId: request.clientId, 
        client: request.client,
        nonce: request.nonce,
        responseMode: request.responseMode,
        state: request.state,
        scope: request.scope
      ))
    }
  }
  
  var legalName: String? {
    switch self {
    case .idToken(let request):
      return request.client.legalName
    case .vpToken(let request):
      return request.client.legalName
    case .idAndVpToken(let request):
      return request.client.legalName
    }
  }
}

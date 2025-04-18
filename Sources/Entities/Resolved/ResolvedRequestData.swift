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
  
  var presentationDefinition: PresentationDefinition? {
    switch self {
    case .vpToken(let request):
      return request.presentationDefinition
    case .idAndVpToken(let request):
      return request.presentationDefinition
    default:
      return nil
    }
  }
  
  var client: Client {
    switch self {
    case .vpToken(let request):
      return request.client
    case .idAndVpToken(let request):
      return request.client
    case .idToken(let request):
      return request.client
    }
  }
}

public extension ResolvedRequestData {
  /// Initializes a `ResolvedRequestData` instance with the provided parameters.
  ///
  /// - Parameters:
  ///   - clientMetaDataResolver: The resolver for client metadata.
  ///   - presentationDefinitionResolver: The resolver for presentation definition.
  ///   - validatedAuthorizationRequest: The validated SiopOpenId4VPRequest.
  init(
    vpConfiguration: VPConfiguration,
    clientMetaDataResolver: ClientMetaDataResolver,
    presentationDefinitionResolver: PresentationDefinitionResolver,
    validatedAuthorizationRequest: ValidatedSiopOpenId4VPRequest
  ) async throws {
    switch validatedAuthorizationRequest {
    case .idToken(let request):
      let clientMetaDataSource = request.clientMetaDataSource
      let clientMetaData = try? await clientMetaDataResolver.resolve(
        source: clientMetaDataSource
      ).get()
      
      let validator = ClientMetaDataValidator()
      let validatedClientMetaData = try? await validator.validate(
        clientMetaData: clientMetaData
      )
      
      self = .idToken(request: .init(
        idTokenType: request.idTokenType,
        clientMetaData: validatedClientMetaData,
        client: request.client,
        nonce: request.nonce,
        responseMode: request.responseMode,
        state: request.state,
        scope: request.scope
      ))
    case .vpToken(let request):
      let clientMetaDataSource = request.clientMetaDataSource
      let clientMetaData = try? await clientMetaDataResolver.resolve(source: clientMetaDataSource).get()
      
      let validator = ClientMetaDataValidator()
      let validatedClientMetaData = try? await validator.validate(clientMetaData: clientMetaData)
      
      guard
        let presentationDefinition = try? await presentationDefinitionResolver.resolve(
          source: request.presentationDefinitionSource
        ).get()
      else {
        throw ResolvedAuthorisationError.invalidPresentationDefinitionData
      }
      
      let common = VpFormats.common(
        request.vpFormats,
        vpConfiguration.vpFormats
      ) ?? request.vpFormats
      
      self = .vpToken(
        request: .init(
          presentationDefinition: presentationDefinition,
          clientMetaData: validatedClientMetaData,
          client: request.client,
          nonce: request.nonce,
          responseMode: request.responseMode,
          state: request.state,
          vpFormats: common,
          transactionData: try Self.parseTransactionData(
            transactionData: request.transactionData,
            vpConfiguration: vpConfiguration,
            presentationDefinition: presentationDefinition
          )
        )
      )
    case .idAndVpToken(request: let request):
      let clientMetaDataSource = request.clientMetaDataSource
      let clientMetaData = try? await clientMetaDataResolver.resolve(source: clientMetaDataSource).get()
      
      let validator = ClientMetaDataValidator()
      let validatedClientMetaData = try? await validator.validate(clientMetaData: clientMetaData)
      
      guard
        let presentationDefinition = try? await presentationDefinitionResolver.resolve(
          source: request.presentationDefinitionSource
        ).get()
      else {
        throw ResolvedAuthorisationError.invalidPresentationDefinitionData
      }
      
      let common = VpFormats.common(
        request.vpFormats,
        vpConfiguration.vpFormats
      ) ?? request.vpFormats
      
      self = .idAndVpToken(request: .init(
        idTokenType: request.idTokenType,
        presentationDefinition: presentationDefinition,
        clientMetaData: validatedClientMetaData,
        client: request.client,
        nonce: request.nonce,
        responseMode: request.responseMode,
        state: request.state,
        scope: request.scope,
        vpFormats: common,
        transactionData: try Self.parseTransactionData(
          transactionData: request.transactionData,
          vpConfiguration: vpConfiguration,
          presentationDefinition: presentationDefinition
        )
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

private extension ResolvedRequestData {
  static func parseTransactionData(
    transactionData: [String]?,
    vpConfiguration: VPConfiguration,
    presentationDefinition: PresentationDefinition
  ) throws -> [TransactionData]? {
    /// If there is no transactionData in the request, return nil.
    guard let data = transactionData else { return nil }
    
    /// For each item in data, attempt to parse and unwrap it.
    return try data.compactMap { item in
      try TransactionData.parse(
        item,
        supportedTypes: vpConfiguration.supportedTransactionDataTypes,
        presentationDefinition: presentationDefinition
      ).get()
    }
  }
}

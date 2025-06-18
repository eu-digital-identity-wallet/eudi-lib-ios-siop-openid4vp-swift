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

public enum ResolvedRequestData: Sendable {
  case idToken(request: IdTokenData)
  case vpToken(request: VpTokenData)
  case idAndVpToken(request: IdAndVpTokenData)

  var presentationDefinition: PresentationDefinition? {
    switch self {
    case .vpToken(let request):
      switch request.presentationQuery {
      case .byPresentationDefinition(let presentationDefinition):
        return presentationDefinition
      case .byDigitalCredentialsQuery:
        return nil
      }
    case .idAndVpToken(let request):
      return request.presentationDefinition
    default:
      return nil
    }
  }

  var dcql: DCQL? {
    switch self {
    case .vpToken(let request):
      switch request.presentationQuery {
      case .byPresentationDefinition:
        return nil
      case .byDigitalCredentialsQuery(let dcql):
        return dcql
      }
    case .idAndVpToken:
      return nil
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
    walletConfiguration: SiopOpenId4VPConfiguration,
    vpConfiguration: VPConfiguration,
    validatedClientMetaData: ClientMetaData.Validated,
    presentationDefinitionResolver: PresentationDefinitionResolver,
    validatedAuthorizationRequest: ValidatedRequestData
  ) async throws {
    switch validatedAuthorizationRequest {
    case .idToken(let request):
      self = .idToken(request: .init(
        idTokenType: request.idTokenType,
        clientMetaData: validatedClientMetaData,
        client: request.client,
        nonce: request.nonce,
        responseMode: request.responseMode,
        state: request.state,
        scope: request.scope,
        jarmRequirement: walletConfiguration.jarmRequirement(validated: validatedClientMetaData)
      ))
    case .vpToken(let request):
      let common = VpFormats.common(
        request.vpFormats,
        vpConfiguration.vpFormats
      ) ?? request.vpFormats

      switch request.querySource {
      case .byPresentationDefinitionSource(let source):
        guard
          let presentationDefinition = try? await presentationDefinitionResolver.resolve(source: source).get()
        else {
          throw ResolvedAuthorisationError.invalidPresentationDefinitionData
        }

        let presentationQuery: PresentationQuery = .byPresentationDefinition(presentationDefinition)

        self = .vpToken(
          request: .init(
            presentationQuery: presentationQuery,
            clientMetaData: validatedClientMetaData,
            client: request.client,
            nonce: request.nonce,
            responseMode: request.responseMode,
            state: request.state,
            vpFormats: common,
            transactionData: try Self.parseTransactionData(
              transactionData: request.transactionData,
              vpConfiguration: vpConfiguration,
              presentationQuery: presentationQuery
            ),
            jarmRequirement: walletConfiguration.jarmRequirement(validated: validatedClientMetaData)
          )
        )
      case .dcqlQuery(let dcql):
        let presentationQuery: PresentationQuery = .byDigitalCredentialsQuery(dcql)

        self = .vpToken(
          request: .init(
            presentationQuery: presentationQuery,
            clientMetaData: validatedClientMetaData,
            client: request.client,
            nonce: request.nonce,
            responseMode: request.responseMode,
            state: request.state,
            vpFormats: common,
            transactionData: try Self.parseTransactionData(
              transactionData: request.transactionData,
              vpConfiguration: vpConfiguration,
              presentationQuery: presentationQuery
            ),
            jarmRequirement: walletConfiguration.jarmRequirement(validated: validatedClientMetaData)
          )
        )
      default: throw ValidationError.validationError("Only presentation definition supported for now")
      }
    case .idAndVpToken(request: let request):
      let common = VpFormats.common(
        request.vpFormats,
        vpConfiguration.vpFormats
      ) ?? request.vpFormats

      switch request.querySource {
      case .byPresentationDefinitionSource(let source):
        guard
          let presentationDefinition = try? await presentationDefinitionResolver.resolve(source: source).get()
        else {
          throw ResolvedAuthorisationError.invalidPresentationDefinitionData
        }

        let presentationQuery: PresentationQuery = .byPresentationDefinition(presentationDefinition)

        self = .idAndVpToken(request: .init(
          idTokenType: request.idTokenType,
          presentationQuery: presentationQuery,
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
            presentationQuery: presentationQuery
          )
        ))
      case .dcqlQuery(let dcql):
        let presentationQuery: PresentationQuery = .byDigitalCredentialsQuery(dcql)

        self = .vpToken(
          request: .init(
            presentationQuery: presentationQuery,
            clientMetaData: validatedClientMetaData,
            client: request.client,
            nonce: request.nonce,
            responseMode: request.responseMode,
            state: request.state,
            vpFormats: common,
            transactionData: try Self.parseTransactionData(
              transactionData: request.transactionData,
              vpConfiguration: vpConfiguration,
              presentationQuery: presentationQuery
            ),
            jarmRequirement: walletConfiguration.jarmRequirement(validated: validatedClientMetaData)
          )
        )
      default: throw ValidationError.validationError("Only presentation definition supported for now")
      }
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
    presentationQuery: PresentationQuery
  ) throws -> [TransactionData]? {
    /// If there is no transactionData in the request, return nil.
    guard let data = transactionData else { return nil }

    /// For each item in data, attempt to parse and unwrap it.
    return try data.compactMap { item in
      try TransactionData.parse(
        item,
        supportedTypes: vpConfiguration.supportedTransactionDataTypes,
        presentationQuery: presentationQuery
      ).get()
    }
  }
}

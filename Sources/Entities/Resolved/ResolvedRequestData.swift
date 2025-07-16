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
import SwiftyJSON

public enum ResolvedRequestData: Sendable {
  case idToken(request: IdTokenData)
  case vpToken(request: VpTokenData)
  case idAndVpToken(request: IdAndVpTokenData)

  public var presentationDefinition: PresentationDefinition? {
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

  public var dcql: DCQL? {
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

  public var client: Client {
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
      let (presentationQuery, _) = try await Self.resolvePresentationQuery(
        from: request.querySource,
        presentationDefinitionResolver: presentationDefinitionResolver
      )

      self = .idToken(request: .init(
        idTokenType: request.idTokenType,
        presentationQuery: presentationQuery,
        clientMetaData: validatedClientMetaData,
        client: request.client,
        nonce: request.nonce,
        responseMode: request.responseMode,
        state: request.state,
        scope: request.scope,
        jarmRequirement: walletConfiguration.jarmRequirement(
          validated: validatedClientMetaData
        ),
        transactionData: try Self.parseTransactionData(
          transactionData: request.transactionData,
          vpConfiguration: vpConfiguration,
          presentationQuery: presentationQuery),
        verifierAttestations: try VerifierAttestation.validatedVerifierAttestations(
          request.verifierAttestations,
          presentationQuery: presentationQuery)
      ))

    case .vpToken(let request):
      let commonFormats = VpFormats.common(request.vpFormats, vpConfiguration.vpFormats) ?? request.vpFormats
      let (presentationQuery, _) = try await Self.resolvePresentationQuery(
        from: request.querySource,
        presentationDefinitionResolver: presentationDefinitionResolver
      )

      self = .vpToken(request: .init(
        presentationQuery: presentationQuery,
        clientMetaData: validatedClientMetaData,
        client: request.client,
        nonce: request.nonce,
        responseMode: request.responseMode,
        state: request.state,
        vpFormats: commonFormats,
        jarmRequirement: walletConfiguration.jarmRequirement(
          validated: validatedClientMetaData
        ),
        transactionData: try Self.parseTransactionData(
          transactionData: request.transactionData,
          vpConfiguration: vpConfiguration,
          presentationQuery: presentationQuery),
        verifierAttestations: try VerifierAttestation.validatedVerifierAttestations(
          request.verifierAttestations,
          presentationQuery: presentationQuery
        )
      ))

    case .idAndVpToken(let request):
      let commonFormats = VpFormats.common(request.vpFormats, vpConfiguration.vpFormats) ?? request.vpFormats
      let (presentationQuery, definition) = try await Self.resolvePresentationQuery(
        from: request.querySource,
        presentationDefinitionResolver: presentationDefinitionResolver
      )

      switch request.querySource {
      case .byPresentationDefinitionSource:
        guard let definition else {
          throw ResolvedAuthorisationError.invalidPresentationDefinitionData
        }
        self = .idAndVpToken(request: .init(
          idTokenType: request.idTokenType,
          presentationQuery: presentationQuery,
          presentationDefinition: definition,
          clientMetaData: validatedClientMetaData,
          client: request.client,
          nonce: request.nonce,
          responseMode: request.responseMode,
          state: request.state,
          scope: request.scope,
          vpFormats: commonFormats,
          transactionData: try Self.parseTransactionData(
            transactionData: request.transactionData,
            vpConfiguration: vpConfiguration,
            presentationQuery: presentationQuery),
          verifierAttestations: try VerifierAttestation.validatedVerifierAttestations(
            request.verifierAttestations,
            presentationQuery: presentationQuery
          )
        ))
      case .dcqlQuery:
        self = .vpToken(request: .init(
          presentationQuery: presentationQuery,
          clientMetaData: validatedClientMetaData,
          client: request.client,
          nonce: request.nonce,
          responseMode: request.responseMode,
          state: request.state,
          vpFormats: commonFormats,
          jarmRequirement: walletConfiguration.jarmRequirement(
            validated: validatedClientMetaData
          ),
          transactionData: try Self.parseTransactionData(
            transactionData: request.transactionData,
            vpConfiguration: vpConfiguration,
            presentationQuery: presentationQuery),
          verifierAttestations: try VerifierAttestation.validatedVerifierAttestations(
            request.verifierAttestations,
            presentationQuery: presentationQuery
          )
        ))
      default:
        throw ValidationError.validationError("Query source by scope is not supported for now")
      }
    }
  }
  
  private static func lookupConfiguredQueries(
    scope: Scope,
    vpConfiguration: VPConfiguration
  ) throws -> PresentationQuery {
    let scopes = scopeItems(from: scope)
    if let definition = scopes
      .compactMap({ vpConfiguration.knownPresentationDefinitionsPerScope[$0] })
      .first {
      return .byPresentationDefinition(definition)
    } else if let dcql = scopes
      .compactMap({ vpConfiguration.knownDCQLQueriesPerScope[$0] })
      .first {
      return .byDigitalCredentialsQuery(dcql)
    } else {
      throw ResolvedAuthorisationError.invalidQueryDataForScope(scope)
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
  
  static func resolvePresentationQuery(
    from source: QuerySource,
    presentationDefinitionResolver: PresentationDefinitionResolver
  ) async throws -> (PresentationQuery, PresentationDefinition?) {
    switch source {
    case .byPresentationDefinitionSource(let source):
      guard
        let presentationDefinition = try? await presentationDefinitionResolver.resolve(source: source).get()
      else {
        throw ResolvedAuthorisationError.invalidPresentationDefinitionData
      }
      return (.byPresentationDefinition(presentationDefinition), presentationDefinition)
      
    case .dcqlQuery(let dcql):
      return (.byDigitalCredentialsQuery(dcql), nil)
      
    default:
      throw ValidationError.validationError("Query source by scope is not supported for now")
    }
  }
  
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

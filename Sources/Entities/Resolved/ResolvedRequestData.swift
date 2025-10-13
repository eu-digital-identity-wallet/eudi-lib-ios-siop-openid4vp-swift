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

  public var dcql: DCQL? {
    switch self {
    case .vpToken(let request):
      switch request.presentationQuery {
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
  init(
    walletConfiguration: SiopOpenId4VPConfiguration,
    vpConfiguration: VPConfiguration,
    validatedClientMetaData: ClientMetaData.Validated,
    validatedAuthorizationRequest: ValidatedRequestData
  ) async throws {

    switch validatedAuthorizationRequest {
    case .idToken(let request):
      let presentationQuery = try await Self.resolvePresentationQuery(
        from: request.querySource
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
        responseEncryptionSpecification: validatedClientMetaData.responseEncryptionSpecification,
        transactionData: try Self.parseTransactionData(
          transactionData: request.transactionData,
          vpConfiguration: vpConfiguration,
          presentationQuery: presentationQuery),
        verifierInfo: try VerifierInfo.validatedVerifierInfo(
          request.verifierInfo,
          presentationQuery: presentationQuery)
      ))

    case .vpToken(let request):
      let commonFormats = VpFormatsSupported.common(request.vpFormatsSupported, vpConfiguration.vpFormatsSupported) ?? request.vpFormatsSupported
      let presentationQuery = try await Self.resolvePresentationQuery(
        from: request.querySource
      )

      self = .vpToken(request: .init(
        presentationQuery: presentationQuery,
        clientMetaData: validatedClientMetaData,
        client: request.client,
        nonce: request.nonce,
        responseMode: request.responseMode,
        state: request.state,
        vpFormatsSupported: commonFormats,
        responseEncryptionSpecification: validatedClientMetaData.responseEncryptionSpecification,
        transactionData: try Self.parseTransactionData(
          transactionData: request.transactionData,
          vpConfiguration: vpConfiguration,
          presentationQuery: presentationQuery),
        verifierInfo: try VerifierInfo.validatedVerifierInfo(
          request.verifierInfo,
          presentationQuery: presentationQuery
        )
      ))

    case .idAndVpToken(let request):
      let commonFormats = VpFormatsSupported.common(request.vpFormatsSupported, vpConfiguration.vpFormatsSupported) ?? request.vpFormatsSupported
      let presentationQuery = try await Self.resolvePresentationQuery(
        from: request.querySource
      )

      switch request.querySource {
      case .dcqlQuery:
        self = .vpToken(request: .init(
          presentationQuery: presentationQuery,
          clientMetaData: validatedClientMetaData,
          client: request.client,
          nonce: request.nonce,
          responseMode: request.responseMode,
          state: request.state,
          vpFormatsSupported: commonFormats,
          responseEncryptionSpecification: validatedClientMetaData.responseEncryptionSpecification, transactionData: try Self.parseTransactionData(
            transactionData: request.transactionData,
            vpConfiguration: vpConfiguration,
            presentationQuery: presentationQuery
          ),
          verifierInfo: try VerifierInfo.validatedVerifierInfo(
            request.verifierInfo,
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
    if let dcql = scopes
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
    from source: QuerySource
  ) async throws -> PresentationQuery {
    switch source {
    case .dcqlQuery(let dcql):
      return .byDigitalCredentialsQuery(dcql)
      
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

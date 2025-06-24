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

extension ResolvedRequestData {
  public struct VpTokenData: Sendable {
    public let presentationQuery: PresentationQuery
    public let clientMetaData: ClientMetaData.Validated?
    public let client: Client
    public let nonce: String
    public let responseMode: ResponseMode?
    public let state: String?
    public let vpFormats: VpFormats
    public let transactionData: [TransactionData]?
    public let jarmRequirement: JARMRequirement?
    
    /// Initializes a `VpTokenData` instance with the provided parameters.
    ///
    /// - Parameters:
    ///   - presentationDefinition: The presentation definition.
    ///   - clientMetaData: The client metadata.
    ///   - clientId: The client ID.
    ///   - nonce: The nonce value.
    ///   - responseMode: The response mode.
    ///   - state: The state value.
    ///   - vpFormats: Vp Formats
    ///   - transactionData: Transaction data
    ///   - jarmRequirement: JARM
    public init(
      presentationQuery: PresentationQuery,
      clientMetaData: ClientMetaData.Validated?,
      client: Client,
      nonce: String,
      responseMode: ResponseMode?,
      state: String?,
      vpFormats: VpFormats,
      transactionData: [TransactionData]? = nil,
      jarmRequirement: JARMRequirement?
    ) {
      self.presentationQuery = presentationQuery
      self.clientMetaData = clientMetaData
      self.client = client
      self.nonce = nonce
      self.responseMode = responseMode
      self.state = state
      self.vpFormats = vpFormats
      self.transactionData = transactionData
      self.jarmRequirement = jarmRequirement
    }
  }
}

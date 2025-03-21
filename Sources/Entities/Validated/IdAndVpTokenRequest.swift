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

extension ValidatedSiopOpenId4VPRequest {
  public struct IdAndVpTokenRequest {
    let idTokenType: IdTokenType
    let querySource: QuerySource
    let clientMetaDataSource: ClientMetaDataSource?
    let clientId: String
    let client: Client
    let nonce: String
    let scope: Scope?
    let responseMode: ResponseMode?
    let state: String?
    let vpFormats: VpFormats
    let transactionData: [String]?
    
    public init(
      idTokenType: IdTokenType,
      querySource: QuerySource,
      clientMetaDataSource: ClientMetaDataSource?,
      clientId: String,
      client: Client,
      nonce: String,
      scope: Scope?,
      responseMode: ResponseMode?,
      state: String?,
      vpFormats: VpFormats,
      transactionData: [String]?
    ) {
      self.idTokenType = idTokenType
      self.querySource = querySource
      self.clientMetaDataSource = clientMetaDataSource
      self.clientId = clientId
      self.client = client
      self.nonce = nonce
      self.scope = scope
      self.responseMode = responseMode
      self.state = state
      self.vpFormats = vpFormats
      self.transactionData = transactionData
    }
  }
}

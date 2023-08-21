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
  public struct VpTokenRequest {
    let presentationDefinitionSource: PresentationDefinitionSource
    let clientMetaDataSource: ClientMetaDataSource?
    let clientIdScheme: ClientIdScheme?
    let clientId: String
    let nonce: String
    let responseMode: ResponseMode?
    let state: String?

    public init(
      presentationDefinitionSource: PresentationDefinitionSource,
      clientMetaDataSource: ClientMetaDataSource?,
      clientIdScheme: ClientIdScheme?,
      clientId: String,
      nonce: String,
      responseMode: ResponseMode?,
      state: String?
    ) {
      self.presentationDefinitionSource = presentationDefinitionSource
      self.clientMetaDataSource = clientMetaDataSource
      self.clientIdScheme = clientIdScheme
      self.clientId = clientId
      self.nonce = nonce
      self.responseMode = responseMode
      self.state = state
    }
  }
}

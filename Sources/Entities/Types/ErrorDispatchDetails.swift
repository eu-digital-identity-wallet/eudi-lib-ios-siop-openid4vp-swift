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
import Foundation

public struct ErrorDispatchDetails {
  public let responseMode: ResponseMode
  public let nonce: String?
  public let state: String?
  public let clientId: VerifierId?
  public let jarmSpec: JarmSpec?
  
  // Default initializer
  public init(
    responseMode: ResponseMode,
    nonce: String? = nil,
    state: String? = nil,
    clientId: VerifierId?,
    jarmSpec: JarmSpec?
  ) {
    self.responseMode = responseMode
    self.nonce = nonce
    self.state = state
    self.clientId = clientId
    self.jarmSpec = jarmSpec
  }
}



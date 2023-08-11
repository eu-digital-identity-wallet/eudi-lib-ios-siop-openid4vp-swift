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

public enum JarmSpec {
  case resolution(holderId: String, jarmOption: JarmOption)
}

public extension JarmSpec {
  init(
    clientMetaData: ClientMetaData?,
    walletOpenId4VPConfig: WalletOpenId4VPConfiguration?
  ) throws {

    guard let clientMetaData = clientMetaData else {
      throw ValidatedAuthorizationError.invalidJarmClientMetadata
    }

    guard let walletOpenId4VPConfig = walletOpenId4VPConfig else {
      throw ValidatedAuthorizationError.invalidWalletConfiguration
    }

    self = .resolution(
      holderId: walletOpenId4VPConfig.decentralizedIdentifier.stringValue,
      jarmOption: try .init(
        clientMetaData: clientMetaData,
        walletOpenId4VPConfig: walletOpenId4VPConfig
      )
    )
  }
}

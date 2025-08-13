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
import JOSESwift
import X509
import SwiftyJSON

// Enum defining the types of validated SIOP OpenID4VP requests
public enum ValidatedRequestData: Sendable {
  case idToken(request: IdTokenRequest)
  case vpToken(request: VpTokenRequest)
  case idAndVpToken(request: IdAndVpTokenRequest)

  public var responseMode: ResponseMode? {
    switch self {
    case .idToken(let request):
      request.responseMode
    case .vpToken(let request):
      request.responseMode
    case .idAndVpToken(let request):
      request.responseMode
    }
  }

  public var nonce: String? {
    switch self {
    case .idToken(let request):
      request.nonce
    case .vpToken(let request):
      request.nonce
    case .idAndVpToken(let request):
      request.nonce
    }
  }

  public var state: String? {
    switch self {
    case .idToken(let request):
      request.state
    case .vpToken(let request):
      request.state
    case .idAndVpToken(let request):
      request.state
    }
  }

  public var clientId: VerifierId {
    switch self {
    case .idToken(let request):
      request.client.id
    case .vpToken(let request):
      request.client.id
    case .idAndVpToken(let request):
      request.client.id
    }
  }
}

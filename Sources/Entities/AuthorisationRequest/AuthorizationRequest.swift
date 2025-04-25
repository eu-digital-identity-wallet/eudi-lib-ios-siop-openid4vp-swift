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

/// An enumeration representing different types of authorization requests.
public enum AuthorizationRequest: Sendable {
  /// A not secured authorization request.
  case notSecured(data: ResolvedRequestData)

  /// A JWT authorization request.
  case jwt(request: ResolvedRequestData)
  
  /// The resolution was not succesful
  case invalidResolution(
    error: AuthorizationRequestError,
    dispatchDetails: ErrorDispatchDetails?
  )
  
  public var resolved: ResolvedRequestData? {
    return switch self {
    case .notSecured(let request):
      request
    case .jwt(let request):
      request
    case .invalidResolution:
      nil
    }
  }
}

/// An extension providing an initializer for the `AuthorizationRequest` enumeration.
public extension AuthorizationRequest {
  
  private static func errorDetails(
    _ authorizationRequestData: UnvalidatedRequestObject? = nil,
    _ validated: ValidatedRequestData? = nil,
    _ walletConfiguration: SiopOpenId4VPConfiguration? = nil
  ) async -> ErrorDispatchDetails? {
    
    func jarmSpec() async throws -> JarmSpec {
      try await JarmSpec(
        clientMetaData: validated?.clientMetaData(),
        walletOpenId4VPConfig: walletConfiguration
      )
    }
    
    return if let validated = validated,
       let responseMode = validated.responseMode {
      await .init(
        responseMode: responseMode,
        nonce: validated.nonce,
        state: validated.state,
        clientId: validated.clientId,
        jarmSpec: try? jarmSpec()
      )
      
    } else if let authorizationRequestData = authorizationRequestData {
      await .init(
        responseMode: authorizationRequestData.validResponseMode,
        nonce: authorizationRequestData.nonce,
        state: authorizationRequestData.state,
        clientId: validated?.clientId,
        jarmSpec: try? jarmSpec()
      )
    } else {
      nil
    }
  }
}

internal extension UnvalidatedRequestObject {
  var validResponseMode: ResponseMode {
    return (try? ResponseMode(authorizationRequestData: self)) ?? .none
  }
}

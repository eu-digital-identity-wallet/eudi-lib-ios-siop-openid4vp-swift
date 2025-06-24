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

public actor ErrorDispatcher: DispatcherType {

  public let service: AuthorisationServiceType

  public let error: AuthorizationRequestError
  public let details: ErrorDispatchDetails?

  public init(
    service: AuthorisationServiceType = AuthorisationService(),
    error: AuthorizationRequestError,
    details: ErrorDispatchDetails?
  ) {
    self.service = service
    self.error = error
    self.details = details
  }

  public func dispatch(poster: any Posting) async throws -> DispatchOutcome {

    guard let response = error.responseWith(details: details) else {
      return .rejected(reason: "Unsupported response mode")
    }

    let result = try await service.formCheck(
      poster: poster,
      response: response
    )

    return result.1 == true ? .accepted(redirectURI: URL(string: result.0)) : .rejected(reason: "")
  }
}

internal extension AuthorizationRequestError {
  func responseWith(details: ErrorDispatchDetails?) -> AuthorizationResponse? {
    let payload: AuthorizationResponsePayload = .invalidRequest(
      error: self,
      nonce: details?.nonce,
      state: details?.state,
      clientId: details?.clientId
    )

    guard let details = details else {
      return nil
    }

    switch details.responseMode {
    case .directPost(let responseURI):
      return .directPost(url: responseURI, data: payload)
    case .directPostJWT(let responseURI):
      guard
        let jarmSpec = details.jarmSpec,
        let jarmRequirement = details.jarmRequirement
      else {
        return nil
      }
      
      return .directPostJwt(
        url: responseURI,
        data: payload,
        jarmRequirement: jarmRequirement
      )
    default:
      return nil
    }
  }
}

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

/// A protocol for an authorization response controller.
public protocol DispatcherType {
  /// Dispatches a response and returns a generic result.
  func dispatch(poster: Posting) async throws -> DispatchOutcome
}

/// An implementation of the `DispatcherType` protocol.
public actor Dispatcher: DispatcherType {
  /// The authorization service used for posting responses.
  public let service: AuthorisationServiceType

  /// The authorization response to be posted.
  public let authorizationResponse: AuthorizationResponse

  /// Initializes an `AuthorizationResponseController` with the provided service and authorization response.
  public init(
    service: AuthorisationServiceType = AuthorisationService(),
    authorizationResponse: AuthorizationResponse
  ) {
    self.service = service
    self.authorizationResponse = authorizationResponse
  }

  /// Posts a response and returns a generic result.
  public func dispatch(
    poster: Posting = Poster()
  ) async throws -> DispatchOutcome {
    let result = try await service.formCheck(
      poster: poster,
      response: self.authorizationResponse
    )

    return result.1 == true ? .accepted(redirectURI: URL(string: result.0)) : .rejected(reason: "")
  }
}

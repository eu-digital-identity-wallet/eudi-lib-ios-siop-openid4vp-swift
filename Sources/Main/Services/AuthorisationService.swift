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

/// A protocol for an authorization service.
public protocol AuthorisationServiceType {
  /// Posts a response and returns a generic result.
  func formPost<T: Codable>(poster: Posting, response: AuthorizationResponse) async throws -> T
  /// Posts a response and returns a success boolean.
  func formCheck(poster: Posting, response: AuthorizationResponse) async throws -> Bool
}

/// An implementation of the `AuthorisationServiceType` protocol.
public actor AuthorisationService: AuthorisationServiceType {

  public init() { }

  /// Posts a response and returns a generic result.
  public func formPost<T: Codable>(
    poster: Posting = Poster(),
    response: AuthorizationResponse
  ) async throws -> T {
    switch response {
    case .directPost(let url, let data):
      let post = VerifierFormPost(
        additionalHeaders: ["Content-Type": ContentType.form.rawValue],
        url: url,
        formData: try data.toDictionary()
      )

      let result: Result<T, PostError> = await poster.post(request: post.urlRequest)
      return try result.get()
    default: throw AuthorizationError.invalidResponseMode
    }
  }

  /// Posts a response and returns a success boolean.
  public func formCheck(poster: Posting, response: AuthorizationResponse) async throws -> Bool {
    switch response {
    case .directPost(let url, let data):
      let post = VerifierFormPost(
        additionalHeaders: ["Content-Type": ContentType.form.rawValue],
        url: url,
        formData: try data.toDictionary()
      )

      let result: Result<Bool, PostError> = await poster.check(request: post.urlRequest)
      return try result.get()
    case .directPostJwt, .query, .queryJwt, .fragment, .fragmentJwt:
      throw AuthorizationError.invalidResponseMode
    }
  }
}

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
import SwiftyJSON

public enum IdTokenType: String, Codable, Sendable {
  case subjectSignedIdToken = "subject_signed_id_token"
  case subjectSigned = "subject_signed"
  case attesterSigned = "attester_signed"

  /// Initializes an `IdTokenType` instance with the given authorization request object.
  ///
  /// - Parameter authorizationRequestObject: The authorization request object.
  /// - Throws: A `ValidatedAuthorizationError.invalidIdTokenType` if the id_token_type is missing,
  ///           or a `ValidatedAuthorizationError.unsupportedIdTokenType` if the id_token_type is unsupported.
  public init(authorizationRequestObject: JSON) throws {
    guard let idTokenType = authorizationRequestObject["id_token_type"].string else {
      throw ValidationError.invalidIdTokenType
    }

    guard let responseType = IdTokenType(rawValue: idTokenType) else {
      throw ValidationError.unsupportedIdTokenType(idTokenType)
    }

    self = responseType
  }

  /// Initializes an `IdTokenType` instance with the given authorization request data.
  ///
  /// - Parameter authorizationRequestData: The authorization request data.
  /// - Throws: A `ValidatedAuthorizationError.invalidIdTokenType` if the id_token_type is missing,
  ///           or a `ValidatedAuthorizationError.unsupportedIdTokenType` if the id_token_type is unsupported.
  public init(authorizationRequestData: UnvalidatedRequestObject) throws {
    guard let idTokenType = authorizationRequestData.idTokenType else {
      throw ValidationError.invalidIdTokenType
    }

    guard let responseType = IdTokenType(rawValue: idTokenType) else {
      throw ValidationError.unsupportedIdTokenType(authorizationRequestData.idTokenType)
    }

    self = responseType
  }
}

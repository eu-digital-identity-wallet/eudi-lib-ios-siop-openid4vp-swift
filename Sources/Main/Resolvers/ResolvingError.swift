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

/// An enumeration representing errors that can occur during the resolution of presentation definitions.
public enum ResolvingError: LocalizedError, Sendable {
  /// The source for resolving presentation definitions is invalid.
  case invalidSource

  /// The specified scopes for resolving presentation definitions are invalid.
  case invalidScopes

  /// A localized description of the error.
  public var errorDescription: String? {
    switch self {
    case .invalidSource:
      return ".invalidSource"
    case .invalidScopes:
      return ".invalidScopes"
    }
  }
}

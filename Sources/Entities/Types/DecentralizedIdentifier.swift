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

public enum DecentralizedIdentifier: Equatable, Sendable {
  case did(String)

  public init(rawValue: String) throws {
    self = .did(rawValue)

    if !isValid() {
      throw JOSEError.invalidDidIdentifier
    }
  }

  /// Returns the string representation of the Decentralized Identifier.
  public var stringValue: String {
    switch self {
    case .did(let value):
      return value
    }
  }

  /// Validates the format of the Decentralized Identifier.
  ///
  /// - Returns: A Boolean value indicating whether the DID is valid.
  public func isValid() -> Bool {
    switch self {
    case .did(let value):
      let regexPattern = "^did:[a-z0-9]+:[a-zA-Z0-9_.-]+$"
      guard let regex = try? NSRegularExpression(pattern: regexPattern, options: []) else {
        return false
      }
      let range = NSRange(location: 0, length: value.utf16.count)
      let matches = regex.matches(in: value, options: [], range: range)
      return !matches.isEmpty
    }
  }
}

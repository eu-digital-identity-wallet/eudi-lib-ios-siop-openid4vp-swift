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

public typealias JWTURI = String
public typealias JWTString = String
public typealias Nonce = String
public typealias Scope = String

public let SCOPE_SEPARATOR = " " // or whatever your separator is

public func scopeItems(from value: Scope) -> [Scope] {
  if value.isEmpty {
    return []
  } else {
    return value
      .split(separator: Character(SCOPE_SEPARATOR))
      .map { Scope($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
  }
}

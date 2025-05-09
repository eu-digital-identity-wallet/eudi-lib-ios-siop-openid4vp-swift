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

@propertyWrapper
public struct Injected<T: Sendable>: Sendable {
  private(set) public var wrappedValue: T
  public init(
    container: DIContainer = DependencyContainer.shared,
    key: String? = nil,
    mode: ResolveMode = .shared
  ) {
    if let key = key {
      wrappedValue = DependencyContainer.shared.resolve(key: key, mode: mode)
    } else {
      wrappedValue = DependencyContainer.shared.resolve(type: T.self, mode: mode)
    }
  }
}

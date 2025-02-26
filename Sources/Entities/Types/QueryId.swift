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

public struct QueryId: Hashable {
  // The underlying value (equivalent to the `value` in the Kotlin value class)
  public let value: String
  
  // Public initializer to ensure the value is valid, similar to the `init` block in Kotlin
  public init(value: String) {
    // Equivalent to `DCQLId.ensureValid(value)` in Kotlin
    DCQLId.ensureValid(value)
    self.value = value
  }
  
  // Public custom description (equivalent to `toString()` in Kotlin)
  public var description: String {
    return value
  }
}

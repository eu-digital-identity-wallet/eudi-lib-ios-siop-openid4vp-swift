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

// Function to extract and convert value to type T
func tryExtract<T>(
    _ key: String,
    from json: [String: Any],
    converter: ((Any) -> T?)? = nil
) throws -> T {
  guard let value = json[key] else {
    throw ValidationError.validationError("\(key) not found")
  }
    
  // If converter is provided, use it to convert the value
  if let converter = converter, let convertedValue = converter(value) {
    return convertedValue
  }
    
  // Handle basic types
  if let typedValue = value as? T {
    return typedValue
  }
    
  // Throw error if conversion fails
  throw ValidationError.validationError("Failed to convert \(key) to expected type")
}

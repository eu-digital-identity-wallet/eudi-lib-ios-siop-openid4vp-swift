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
import SwiftyJSON
import Foundation

extension JSON {
  /// Decodes the `SwiftyJSON.JSON` object into a specified `Decodable` type.
  /// - Parameter type: The type of the object to decode.
  /// - Returns: An instance of the specified type, if decoding is successful.
  /// - Throws: An error if the JSON data is invalid or if decoding fails.
  func decoded<T: Decodable>(as type: T.Type) throws -> T {
    let jsonData = try self.rawData()
    return try JSONDecoder().decode(T.self, from: jsonData)
  }

  /// Retrieves a required string value from a JSON object.
  /// - Parameter name: The key of the required string property.
  /// - Throws: An error if the property is missing or not a string.
  /// - Returns: The string value associated with the given key.
  func requiredString(_ name: String) throws -> String {
    guard let value = self[name].string else {
      throw ValidationError.validationError(
        "Missing or invalid required property '\(name)'"
      )
    }
    return value
  }

  /// Retrieves a required array of strings from a JSON object.
  /// - Parameter name: The key of the required string array property.
  /// - Throws: An error if the property is missing, not an array, or contains non-string values.
  /// - Returns: An array of strings associated with the given key.
  func requiredStringArray(_ name: String) throws -> [String] {
    guard let array = self[name].array, array.allSatisfy({ $0.string != nil }) else {
      throw ValidationError.validationError(
        "Property '\(name)' is not an array or contains non-string values"
      )
    }
    return array.compactMap { $0.string }
  }

  /// Retrieves an optional array of strings from a JSON object.
  /// - Parameter name: The key of the optional string array property.
  /// - Returns: An array of strings if the property exists and is valid, otherwise `nil`.
  func optionalStringArray(_ name: String) -> [String]? {
    guard let array = self[name].array, array.allSatisfy({ $0.string != nil }) else {
      return nil
    }
    return array.compactMap { $0.string }
  }
}

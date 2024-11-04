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
}

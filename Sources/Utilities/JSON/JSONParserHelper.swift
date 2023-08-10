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

internal func getStringValue(
  from dictionary: [String: Any],
  for key: String,
  error: LocalizedError
) throws -> String {
  guard let value = dictionary[key] as? String else {
    throw error
  }
  return value
}

internal func getNumericValue(
  from dictionary: [String: Any],
  for key: String,
  error: LocalizedError
) throws -> Int64 {
  guard let value = dictionary[key] as? Int64 else {
    throw error
  }
  return value
}

internal func getValue<T: Codable>(
  from dictionary: [String: Any],
  for key: String,
  error: LocalizedError
) throws -> T {
  guard let value = dictionary[key] as? T else {
    throw error
  }
  return value
}

internal func getStringArrayValue(
  from metaData: [String: Any],
  for key: String,
  error: LocalizedError
) throws -> [String] {
  guard let value = metaData[key] as? [String] else {
    throw error
  }
  return value
}

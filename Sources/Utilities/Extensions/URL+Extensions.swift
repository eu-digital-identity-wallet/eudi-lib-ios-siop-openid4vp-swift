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

package extension URL {
  /// Checks whether a given string is a valid URL with a host and supported scheme.
  static func isValid(_ urlString: String) -> Bool {
    guard let url = URL(string: urlString),
          url.host != nil else {
      return false
    }
    return true
  }
  
  /// Returns the host component of the URL, optionally removing percent encoding.
  func host(includePercentEncoding: Bool) -> String? {
    guard let host = self.host else {
      return nil
    }
    return includePercentEncoding ? host : host.removingPercentEncoding
  }
  
  var queryParameters: [String: Any]? {
    guard
      let components = URLComponents(string: self.absoluteString),
      let queryItems = components.queryItems else { return nil }
    return queryItems.reduce(into: [String: String]()) { (result, item) in
        result[item.name] = item.value?.removingPercentEncoding
    }
  }
}

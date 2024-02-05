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

extension URLRequest {
  func toCurlCommand() -> String {
    var curlCommand = "curl -v"
    
    if let httpMethod = httpMethod {
      curlCommand += " -X \(httpMethod)"
    }
    
    if let url = url {
      curlCommand += " '\(url.absoluteString)'"
    }
    
    if let allHTTPHeaderFields = allHTTPHeaderFields {
      for (key, value) in allHTTPHeaderFields {
        curlCommand += " -H '\(key): \(value)'"
      }
    }
    
    if let httpBody = httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
      curlCommand += " -d '\(bodyString)'"
    }
    
    return curlCommand
  }
}

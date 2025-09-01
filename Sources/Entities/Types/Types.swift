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

public typealias OriginalClientId = String

public typealias CoseAlgorithm = Int

public enum RequestUriMethod: CustomStringConvertible, Sendable {
  case GET, POST
  
  public var description: String {
    switch self {
    case .GET:
      return "GET"
    case .POST:
      return "POST"
    }
  }
  
  public init(method: String?) {
    guard let method = method else {
      self = .GET
      return
    }
    
    switch method.uppercased() {
    case "GET":
      self = .GET
    case "POST":
      self = .POST
    default:
      self = .GET
    }
  }
}

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

public class JoseAlgorithm: Hashable {
  
  public static func == (lhs: JoseAlgorithm, rhs: JoseAlgorithm) -> Bool {
    lhs.hashValue == rhs.hashValue
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.name)
    hasher.combine(self.requirement)
  }
  
  public let name: String
  public let requirement: Requirement
  
  public init(name: String, requirement: Requirement) {
    self.name = name
    self.requirement = requirement
  }
  
  public init(name: String) {
    self.name = name
    self.requirement = .OPTIONAL
  }
  
  public func toJson() throws -> String {
    let data = try JSONSerialization.data(withJSONObject: [self.name])
    guard let value = String(data: data, encoding: .utf8) else {
      throw ValidatedAuthorizationError.invalidFormat
    }
    return value
  }
  
}

public extension JoseAlgorithm {
  enum Requirement: Hashable {
    case REQUIRED
    case RECOMMENDED
    case OPTIONAL
  }
}

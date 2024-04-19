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

public typealias Base64URL = String

public enum VpToken {
  case generic(String)
  case msoMdoc(String, apu: Base64URL) // Assuming apu is a string
  
  public var value: String {
    switch self {
    case .generic(let value), 
         .msoMdoc(let value, _):
      return value
    }
  }
  
  public var apu: String? {
    switch self {
    case .msoMdoc(_, let apu):
      return apu
    default:
      return nil
    }
  }
}

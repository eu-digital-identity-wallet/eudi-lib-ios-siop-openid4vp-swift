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
import SwiftyJSON

public struct JSONWebToken {
  public let header: JSONWebTokenHeader
  public let payload: JSON
  public let signature: String

  /**
   Initializes a JSONWebToken instance with the provided components.
   
   - Parameters:
   - header: The header component of the JSON Web Token.
   - payload: The payload component of the JSON Web Token.
   - signature: The signature component of the JSON Web Token.
   */
  public init(header: JSONWebTokenHeader, payload: JSON, signature: String) {
    self.header = header
    self.payload = payload
    self.signature = signature
  }
}

public extension JSONWebToken {
  /**
   Initializes a JSONWebToken instance from a string representation of a JSON Web Token.
   
   - Parameters:
   - jsonWebToken: The string representation of the JSON Web Token.
   
   - Returns: A new JSONWebToken instance, or `nil` if the initialization fails.
   */
  init?(jsonWebToken: String) {
    let encodedData = { (string: String) -> Data? in
      var encodedString = string.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")

      switch encodedString.utf16.count % 4 {
      case 2: encodedString = "\(encodedString)=="
      case 3: encodedString = "\(encodedString)="
      default: break
      }
      return Data(base64Encoded: encodedString)
    }

    let components = jsonWebToken.components(separatedBy: ".")

    guard
      components.count == 3,
      let headerData = encodedData(components[0] as String),
      let payloadData = encodedData(components[1] as String)
    else {
      return nil
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    do {
      header = try decoder.decode(JSONWebTokenHeader.self, from: headerData)
      let object = try JSONSerialization.jsonObject(with: payloadData, options: .allowFragments)
      payload = JSON(object)
      signature = components[2] as String
    } catch {
      return nil
    }
  }
}

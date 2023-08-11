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

public struct WebKeySet: Codable, Equatable {
  public let keys: [Key]

  public init(keys: [Key]) {
    self.keys = keys
  }

  public init(_ json: JSONObject) throws {
    guard let keys = json["keys"] as? [JSONObject] else {
      throw ValidatedAuthorizationError.invalidJWTWebKeySet
    }
    self.keys = try WebKeySet.transformToKey(keys)
  }

  public init(_ json: String) throws {
    guard
      let keySet = try json.convertToDictionary(),
      let keys = keySet["keys"] as? [JSONObject]
    else {
      throw ValidatedAuthorizationError.invalidJWTWebKeySet
    }
    self.keys = try WebKeySet.transformToKey(keys)
  }
}

public extension WebKeySet {
  struct Key: Codable, Equatable {

    public let kty: String
    public let use: String
    public let kid: String
    public let iat: Int64
    public let exponent: String
    public let modulus: String

    /// Coding keys for encoding and decoding the structure.
    enum CodingKeys: String, CodingKey {
      case kty
      case use
      case kid
      case iat
      case exponent = "e"
      case modulus = "n"
    }

    public init(
      kty: String,
      use: String,
      kid: String,
      iat: Int64,
      exponent: String,
      modulus: String
    ) {
      self.kty = kty
      self.use = use
      self.kid = kid
      self.iat = iat
      self.exponent = exponent
      self.modulus = modulus
    }
  }
}

fileprivate extension WebKeySet {

  @ArrayBuilder<WebKeySet.Key>
  static func transformToKey(_ keys: [JSONObject]) throws -> [WebKeySet.Key] {
    for key in keys {
      WebKeySet.Key(
        kty: try getStringValue(
          from: key,
          for: "kty",
          error: ValidatedAuthorizationError.invalidJWTWebKeySet
        ),
        use: try getStringValue(
          from: key,
          for: "use",
          error: ValidatedAuthorizationError.invalidJWTWebKeySet
        ),
        kid: try getStringValue(
          from: key,
          for: "kid",
          error: ValidatedAuthorizationError.invalidJWTWebKeySet
        ),
        iat: try getNumericValue(
          from: key,
          for: "iat",
          error: ValidatedAuthorizationError.invalidJWTWebKeySet
        ),
        exponent: try getStringValue(
          from: key,
          for: "e",
          error: ValidatedAuthorizationError.invalidJWTWebKeySet
        ),
        modulus: try getStringValue(
          from: key,
          for: "n",
          error: ValidatedAuthorizationError.invalidJWTWebKeySet
        )
      )
    }
  }
}

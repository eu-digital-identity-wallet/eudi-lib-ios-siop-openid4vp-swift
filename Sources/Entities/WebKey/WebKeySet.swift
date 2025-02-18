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
import JOSESwift
import SwiftyJSON

public struct WebKeySet: Codable, Equatable {
  public let keys: [Key]

  public init(keys: [Key]) {
    self.keys = keys
  }

  public init(_ json: JSON) throws {
    guard let keys = json["keys"].array else {
      throw ValidationError.invalidJWTWebKeySet
    }
    self.keys = try WebKeySet.transformToKey(keys)
  }

  public init(_ json: String) throws {
    guard
      let keySet = try? JSON(json.convertToDictionary() ?? [:]),
      let keys = keySet["keys"].array
    else {
      throw ValidationError.invalidJWTWebKeySet
    }
    self.keys = try WebKeySet.transformToKey(keys)
  }
}

public extension WebKeySet {
  struct Key: Codable, Equatable, Hashable {

    public let kty: String
    public let use: String
    public let kid: String
    public let iat: Int64?
    
    public let crv: String?
    public let x: String?
    public let y: String?
    
    public let exponent: String?
    public let modulus: String?
    
    public let alg: String?

    /// Coding keys for encoding and decoding the structure.
    enum CodingKeys: String, CodingKey {
      case kty
      case use
      case kid
      case iat
      
      case crv
      case x
      case y
      
      case exponent = "e"
      case modulus = "n"
      
      case alg
    }

    public init(
      kty: String,
      use: String,
      kid: String,
      iat: Int64?,
      crv: String?,
      x: String?,
      y: String?,
      exponent: String?,
      modulus: String?,
      alg: String?
    ) {
      self.kty = kty
      self.use = use
      self.kid = kid
      self.iat = iat
      self.crv = crv
      self.x = x
      self.y = y
      self.exponent = exponent
      self.modulus = modulus
      self.alg = alg

    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(kid)
      hasher.combine(kty)
      hasher.combine(use)
      hasher.combine(iat)
      hasher.combine(exponent)
      hasher.combine(modulus)
      hasher.combine(alg)
    }
  }
}

fileprivate extension WebKeySet {

  @ArrayBuilder<WebKeySet.Key>
  static func transformToKey(_ keys: [JSON]) throws -> [WebKeySet.Key] {
    let dictionaries: [[String: Any]] = keys.compactMap { $0.dictionaryObject }
    for key in dictionaries {
      WebKeySet.Key(
        kty: try key.getValue(
          for: "kty",
          error: ValidationError.validationError("key set key \"kty\" not found")
        ),
        use: try key.getValue(
          for: "use",
          error: ValidationError.validationError("key set key  \"use\" not found")
        ),
        kid: try key.getValue(
          for: "kid",
          error: ValidationError.validationError("key set key  \"kid\" not found")
        ),
        iat: try key.getValue(
          for: "iat",
          error: ValidationError.validationError("key set key  \"iat\" not found")
        ),
        crv: try? key.getValue(
          for: "crv",
          error: ValidationError.validationError("key set key  \"crv\" not found")
        ),
        x: try? key.getValue(
          for: "x",
          error: ValidationError.validationError("key set key  \"x\" not found")
        ),
        y: try? key.getValue(
          for: "y",
          error: ValidationError.validationError("key set key  \"y\" not found")
        ),
        exponent: try? key.getValue(
          for: "e",
          error: ValidationError.validationError("key set key  \"x\" not found")
        ),
        modulus: try? key.getValue(
          for: "n",
          error: ValidationError.validationError("key set key  \"x\" not found")
        ),
        alg: try? key.getValue(
          for: "alg",
          error: ValidationError.validationError("key set key  \"y\" not found")
        )
      )
    }
  }
}

public extension WebKeySet {
  init(jwk: JWK) throws {
    self.keys = try WebKeySet.transformToKey(
      [JSON(jwk.toDictionary())]
    )
  }
  
  init(jwks: [JWK]) throws {
    self.keys = try WebKeySet.transformToKey(jwks.map {
      try JSON($0.toDictionary())
    })
  }
}

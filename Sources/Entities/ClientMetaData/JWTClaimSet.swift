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

public struct JWTClaimsSet {

  private struct JWTClaimNames {
    static let ISSUER = "iss"
    static let SUBJECT = "sub"
    static let AUDIENCE = "aud"
    static let EXPIRATION_TIME = "exp"
    static let NOT_BEFORE = "nbf"
    static let ISSUED_AT = "iat"
    static let JWT_ID = "jti"
  }

  public let issuer: String?
  public let subject: String?
  public let audience: [String]
  public let expirationTime: Date?
  public let notBeforeTime: Date?
  public let issueTime: Date?
  public let jwtID: String?
  public let claims: [String: Any]

  public init(
    issuer: String?,
    subject: String?,
    audience: [String],
    expirationTime: Date?,
    notBeforeTime: Date?,
    issueTime: Date?,
    jwtID: String?,
    claims: [String: Any]
  ) {
    self.issuer = issuer
    self.subject = subject
    self.audience = audience
    self.expirationTime = expirationTime
    self.notBeforeTime = notBeforeTime
    self.issueTime = issueTime
    self.jwtID = jwtID
    self.claims = claims
  }

  private static func parseDateClaim(_ name: String, from dictionary: [String: Any]) throws -> Date? {
    if let timestamp = dictionary[name] as? Int64 {
      return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
    return nil
  }

  private static func getStringArrayClaim(_ name: String, from dictionary: [String: Any]) throws -> [String]? {
    if let list = dictionary[name] as? [Any] {
      var stringArray = [String]()
      for item in list {
        if let string = item as? String {
          stringArray.append(string)

        } else {
          throw parseException("The \(name) claim is not a list / JSON array of strings")
        }
      }
      return stringArray
    }
    return nil
  }

  public static func parse(_ json: [String: Any]) throws -> JWTClaimsSet {
    var claims = [String: Any]()

    for (name, value) in json {
      switch name {
      case JWTClaimNames.ISSUER:
        if let issuer = value as? String {
          claims[JWTClaimNames.ISSUER] = issuer
        } else {
          throw parseException("The \(JWTClaimNames.ISSUER) claim is not a String")
        }
      case JWTClaimNames.SUBJECT:
        if let subject = value as? String {
          claims[JWTClaimNames.SUBJECT] = subject
        } else {
          throw parseException("The \(JWTClaimNames.SUBJECT) claim is not a String")
        }
      case JWTClaimNames.AUDIENCE:
        if let audienceArray = try getStringArrayClaim(JWTClaimNames.AUDIENCE, from: json) {
          if audienceArray.count == 1 {
            claims[JWTClaimNames.AUDIENCE] = audienceArray[0]
          } else {
            claims[JWTClaimNames.AUDIENCE] = audienceArray
          }
        } else if let audience = value as? String {
          claims[JWTClaimNames.AUDIENCE] = audience
        } else {
          claims[JWTClaimNames.AUDIENCE] = nil
        }
      case JWTClaimNames.EXPIRATION_TIME:
        if let expirationTime = try parseDateClaim(JWTClaimNames.EXPIRATION_TIME, from: json) {
          claims[JWTClaimNames.EXPIRATION_TIME] = expirationTime
        }
      case JWTClaimNames.NOT_BEFORE:
        if let notBeforeTime = try parseDateClaim(JWTClaimNames.NOT_BEFORE, from: json) {
          claims[JWTClaimNames.NOT_BEFORE] = notBeforeTime
        }
      case JWTClaimNames.ISSUED_AT:
        if let issueTime = try parseDateClaim(JWTClaimNames.ISSUED_AT, from: json) {
          claims[JWTClaimNames.ISSUED_AT] = issueTime
        }
      case JWTClaimNames.JWT_ID:
        if let jwtID = value as? String {
          claims[JWTClaimNames.JWT_ID] = jwtID
        } else {
          throw parseException("The \(JWTClaimNames.JWT_ID) claim is not a String")
        }
      default:
        claims[name] = value
      }
    }

    let issuer = claims[JWTClaimNames.ISSUER] as? String
    let subject = claims[JWTClaimNames.SUBJECT] as? String
    let audience = try getStringArrayClaim(JWTClaimNames.AUDIENCE, from: claims) ?? []
    let expirationTime = claims[JWTClaimNames.EXPIRATION_TIME] as? Date
    let notBeforeTime = claims[JWTClaimNames.NOT_BEFORE] as? Date
    let issueTime = claims[JWTClaimNames.ISSUED_AT] as? Date
    let jwtID = claims[JWTClaimNames.JWT_ID] as? String

    return JWTClaimsSet(
      issuer: issuer,
      subject: subject,
      audience: audience,
      expirationTime: expirationTime,
      notBeforeTime: notBeforeTime,
      issueTime: issueTime,
      jwtID: jwtID,
      claims: claims
    )
  }

  private static func parseException(_ message: String) -> Error {
    let userInfo = [NSLocalizedDescriptionKey: message]
    return NSError(domain: "JWTClaimsSet.parse", code: 0, userInfo: userInfo)
  }

  public static func parse(_ jsonString: String) throws -> JWTClaimsSet {
    if let jsonData = jsonString.data(using: .utf8),
       let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
      return try parse(jsonObject)
    }
    throw parseException("Failed to parse JSON string")
  }
}

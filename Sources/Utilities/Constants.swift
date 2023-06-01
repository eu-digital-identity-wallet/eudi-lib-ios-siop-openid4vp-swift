import Foundation
import CryptoKit
import PresentationExchange

// swiftlint:disable line_length
public struct Constants {
  public static let CLIENT_ID = "client_id"
  public static let NONCE = "nonce"
  public static let SCOPE = "scope"
  public static let STATE = "state"
  public static let HTTPS = "https"
  public static let PRESENTATION_DEFINITION = "presentation_definition"
  public static let PRESENTATION_DEFINITION_URI = "presentation_definition_uri"

  public static func testClientMetaData() -> ClientMetaData {
    .init(
      jwksUri: "https://jwks.uri",
      idTokenSignedResponseAlg: ".idTokenSignedResponseAlg",
      idTokenEncryptedResponseAlg: ".idTokenEncryptedResponseAlg",
      idTokenEncryptedResponseEnc: ".idTokenEncryptedResponseEnc",
      subjectSyntaxTypesSupported: []
    )
  }

  public static let testClientId = "https%3A%2F%2Fclient.example.org%2Fcb"
  public static let testNonce = "0S6_WzA2Mj"
  public static let testScope = "one two three"

  public static let testResponseMode: ResponseMode = .directPost(responseURI: URL(string: "https://respond.here")!)

  static func generateRandomJWT() -> String {
    // Define the header
    let header = #"{"alg":"HS256","typ":"JWT"}"#

    // Define the claims
    let claims = #"{"iss":"issuer","sub":"subject","aud":["audience"],"exp":1679911600,"iat":1657753200}"#

    // Create the base64url-encoded segments
    let encodedHeader = header.base64urlEncode
    let encodedClaims = claims.base64urlEncode

    // Concatenate the header and claims segments with a dot separator
    let encodedToken = "\(encodedHeader).\(encodedClaims)"

    // Define the secret key for signing
    let secretKey = "your_secret_key".data(using: .utf8)!

    // Sign the token with HMAC-SHA256
    let signature = HMAC<SHA256>.authenticationCode(for: Data(encodedToken.utf8), using: SymmetricKey(data: secretKey))

    // Base64url-encode the signature
    let encodedSignature = Data(signature).base64EncodedString()

    // Concatenate the encoded token and signature with a dot separator
    let jwt = "\(encodedToken).\(encodedSignature)"

    return jwt
  }

  static func generateRandomBase64String() -> String? {
    let randomData = Data.randomData(length: 32)
    let base64URL = randomData.base64URLEncodedString()
    return base64URL
  }

  static let der = "MIIEowIBAAKCAQEAv5imITebNZFdmRRJuej90PKTQxvLgBh/cLwoGrJvvc9+y0VPQ3KFQvuEcWMvMPVMQkLG+5FBnPe6iz+eeLQutNI0Lq4QhotasDVIBe+TnZkxd3Ys6T7V5AjsYk3V0oxW7uQHdB3z/yox657v43+4P+qPEJxRv3Es3Ii8EPJwaupKnn1Wp1JqoFW1VVzJcKCSSf3AkyhfINPPLOhDDEkuG0/+pfZXqwd4OdhYXx/cI2oOV3wrIV3vJQ98R1UsOlbyZuAYznsNwLLe4TL3UgBUDBVSAz/AVc4LaLqfJ7JjS8KSn+77eW/FfNMERczloZt3fHgqg9TrHIoXR6pBnLaBZQIDAQABAoIBAENgpDOUQYHSEA9QQikd1XyQgdccxDDU7KQxlwzkaUVf3eAQDLLUaCbJGqdhUOwvp1S59Q3s5B0WRUTI56rc+nveXDl6PxeBlC/ZXO2xdcD7aZjwNxUDYuaheLeNVb+IWN4D1Ncx3WeDaDDLIONpO9tGWm9l+Z2QaE1ZzIFNMNl31V5blxkmfKPjPRZR9W9CMgpuRzjjrJLOyHYMc8T9R17AGo32kO4JshG/9MtVfe0pc32idwNgpI2hVKQENH01abwEHVeJVI/2c3IAT0FMORquyuDgQ+Nrcc67kSZiRCUTZgeoCOKmWTVE/51DFQpiWyrjXwNCoDm6lSMrdbL1U0ECgYEA4jhtd3hA9HSkhdEX9wGmFHy5TkYUSF5CCTJkqJvHpF5+jU9N2lHl4ZDetBxLfBe1Syq1dnrslstUGikFFRVrJnuQd4PSbYFZ0fAT2cqg3cABc/m27fEECNf8kl8+x/YkHXzkaftMZjmAvL8TIbYY3DIqcXMi2RWGHtKspRyu83ECgYEA2NFlgeSSvzMrQom7u6kFQGFUd7sc5Gc/rydvSgxCFi73knu2VMD4cbuloLbm+k1+N1aygS29IkwXy/AeE+hDSB8CFTzxvGnVtUkkWCBgbIuugMTuddNJAJM8yl7S0QDT3MV9v+HT16FyMXaiR7r0MCz2S4ZaTYQ5WxXYpW/sSzUCgYEAsAR54Fh4Kf1MOjbsb6wfvpchVC8g/wIgXamROsQjPdisnWUUTYgl1zHypq/RaBfGX1s24J5a0iYZJVW/d503xzSjvuqZ48yex8QGnhKUwpXwS34EgPVkT0FHa9iiL9JsXWldDL2Uv4GEktgVmchnZYW/EpEkj0a5GeiQntRHqHECgYAEq95IAii3Pd78vALzdBzM2kv7mGhy81aH642WRtVVrQVgfpHbGZ1Atg5HfClV0z2Y66FE7ztX9dO9bRr4ytRIRYLB+mIq8QzNrxm9XFU3gXrtA1Ev8LFt9b4ljg10u1PVOdwPuknaJ3xSXH/6k6iXMSDNV8OyT9r8f2f/iH3K0QKBgEw2E9dS/7hCzHYV4hqxWsSapqoU5S59REBzH0tkSwkfXgjleHwGOoRBH6RzE5FsfBfUzG1wPtlw74a2J10Ko+gPESCbHZsH9KgONCsUoa45Kq7paptUYxwWKez1+o9For0oNRfVlvKPkyA8sRV3SkRsURXNX0mRdcsu+GPrYQCG"
}
// swiftlint:enable line_length

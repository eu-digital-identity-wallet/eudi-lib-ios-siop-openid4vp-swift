import Foundation

public struct JWTClaimNames {

  // RFC 7519 "iss" (Issuer) Claim
  public static let issuer = "iss"

  // RFC 7519 "sub" (Subject) Claim
  public static let subject = "sub"

  // RFC 7519 "aud" (Audience) Claim
  public static let audience = "aud"

  // RFC 7519 "exp" (Expiration Time) Claim
  public static let expirationTime = "exp"

  // RFC 7519 "nbf" (Not Before) Claim
  public static let notBefore = "nbf"

  // RFC 7519 "iat" (Issued At) Claim
  public static let issuedAt = "iat"

  // RFC 7519 "jti" (JWT ID) Claim
  public static let jwtId = "jti"

  private init() {}
}

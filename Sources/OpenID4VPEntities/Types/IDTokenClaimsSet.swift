import Foundation

struct IDTokenClaimsSet: Codable {
  let iss: String
  let sub: String
  let aud: String
  let nonce: String
  let exp: Int
  let iat: Int
  let authTime: Int
  let acr: String
  let atHash: String

  enum CodingKeys: String, CodingKey {
    case iss
    case sub
    case aud
    case nonce
    case exp
    case iat
    case authTime = "auth_time"
    case acr
    case atHash = "at_hash"
  }
}

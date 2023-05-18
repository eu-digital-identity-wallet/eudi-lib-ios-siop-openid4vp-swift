import Foundation
import PresentationExchange

public struct RemoteJWT: Codable, Equatable {
  let jwt: JWTString

  public init(jwt: JWTString) {
    self.jwt = jwt
  }
}

extension RemoteJWT {

  enum Key: String, CodingKey {
    case jwt
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: Key.self)
    try? container.encode(jwt, forKey: .jwt)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Key.self)
    jwt = try container.decode(String.self, forKey: .jwt)

    if !jwt.isValidJWT() {
      throw JSONParseError.invalidJWT
    }
  }
}

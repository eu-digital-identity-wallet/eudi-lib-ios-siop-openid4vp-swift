import Foundation

public struct JSONWebTokenHeader {
  public let kid: String?
  public let type: String?
  public let algorithm: String

  public init(kid: String?, type: String?, algorithm: String) {
    self.kid = kid
    self.type = type
    self.algorithm = algorithm
  }
}

extension JSONWebTokenHeader: Codable, Equatable {

  enum Key: String, CodingKey {
    case kid       = "kid"
    case type      = "typ"
    case algorithm = "alg"
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: Key.self)
    try? container.encode(kid, forKey: .kid)
    try? container.encode(type, forKey: .type)
    try container.encode(algorithm, forKey: .algorithm)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Key.self)
    kid = try? container.decode(String.self, forKey: .kid)
    type = try? container.decode(String.self, forKey: .type)
    algorithm = try container.decode(String.self, forKey: .algorithm)
  }
}

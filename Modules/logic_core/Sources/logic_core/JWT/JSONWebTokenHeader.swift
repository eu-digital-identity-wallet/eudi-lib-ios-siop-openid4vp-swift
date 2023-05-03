import Foundation

public struct JSONWebTokenHeader {
  public let type: String
  public let algorithm: String

  public init(type: String, algorithm: String) {
    self.type = type
    self.algorithm = algorithm
  }
}

extension JSONWebTokenHeader: Codable {

  enum Key: String, CodingKey {
    case type      = "typ"
    case algorithm = "alg"
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: Key.self)
    try container.encode(type, forKey: .type)
    try container.encode(algorithm, forKey: .algorithm)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Key.self)
    type = try container.decode(String.self, forKey: .type)
    algorithm = try container.decode(String.self, forKey: .algorithm)
  }
}

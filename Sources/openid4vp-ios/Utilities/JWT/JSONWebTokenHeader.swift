import Foundation

struct JSONWebTokenHeader {
  let type: String
  let algorithm: String
}

extension JSONWebTokenHeader: Codable {

  private enum Key: String, CodingKey {
    case type      = "typ"
    case algorithm = "alg"
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: Key.self)
    try container.encode(type, forKey: .type)
    try container.encode(algorithm, forKey: .algorithm)
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Key.self)
    type = try container.decode(String.self, forKey: .type)
    algorithm = try container.decode(String.self, forKey: .algorithm)
  }
}

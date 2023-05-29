import Foundation

public struct JSONWebTokenHeader {
  public let kid: String?
  public let type: String?
  public let algorithm: String

  /**
   Initializes a JSONWebTokenHeader instance with the provided components.

   - Parameters:
      - kid: The key identifier.
      - type: The type of the token.
      - algorithm: The algorithm used to sign the token.
   */
  public init(kid: String?, type: String?, algorithm: String) {
    self.kid = kid
    self.type = type
    self.algorithm = algorithm
  }
}

extension JSONWebTokenHeader: Codable, Equatable {
  /**
   Coding keys used for encoding and decoding JSONWebTokenHeader.

   - Key: kid - The key identifier.
          type - The type of the token.
          algorithm - The algorithm used to sign the token.
   */
  enum Key: String, CodingKey {
    case kid       = "kid"
    case type      = "typ"
    case algorithm = "alg"
  }

  /**
   Encodes the JSONWebTokenHeader into the provided encoder.

   - Parameters:
      - encoder: The encoder to encode the JSONWebTokenHeader to.
   */
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: Key.self)
    try? container.encode(kid, forKey: .kid)
    try? container.encode(type, forKey: .type)
    try container.encode(algorithm, forKey: .algorithm)
  }

  /**
   Initializes a JSONWebTokenHeader instance by decoding from the provided decoder.

   - Parameters:
      - decoder: The decoder to decode the JSONWebTokenHeader from.
   */
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Key.self)
    kid = try? container.decode(String.self, forKey: .kid)
    type = try? container.decode(String.self, forKey: .type)
    algorithm = try container.decode(String.self, forKey: .algorithm)
  }
}

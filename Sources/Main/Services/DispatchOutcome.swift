import Foundation

public enum DispatchOutcome: Codable, Equatable {
  case accepted(redirectURI: URL?)
  case rejected(reason: String)

  enum CodingKeys: String, CodingKey {
    case accepted
    case rejected
  }
}

public extension DispatchOutcome {

  internal init() {
    self = .accepted(redirectURI: nil)
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if container.contains(.accepted) {
      let redirectURI = try container.decode(URL?.self, forKey: .accepted)
      self = .accepted(redirectURI: redirectURI)
    } else if container.contains(.rejected) {
      let reason = try container.decode(String.self, forKey: .rejected)
      self = .rejected(reason: reason)
    } else {
      throw DecodingError.dataCorruptedError(
          forKey: CodingKeys.accepted,
          in: container,
          debugDescription: "Invalid DispatchOutcome"
      )
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .accepted(let redirectURI):
      try container.encode(redirectURI, forKey: .accepted)
    case .rejected(let reason):
      try container.encode(reason, forKey: .rejected)
    }
  }
}

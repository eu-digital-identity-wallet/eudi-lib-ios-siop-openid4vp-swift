import Foundation

public enum SubjectSyntaxType: Equatable {
  case jwkThumbprint(String)
  case decentralizedIdentifier(String)
}

public extension SubjectSyntaxType {

  init(thumbprint: String) {
    self = .jwkThumbprint(thumbprint)
  }

  init(decentralizedIdentifier: String) {
    self = .decentralizedIdentifier(decentralizedIdentifier)
  }
}

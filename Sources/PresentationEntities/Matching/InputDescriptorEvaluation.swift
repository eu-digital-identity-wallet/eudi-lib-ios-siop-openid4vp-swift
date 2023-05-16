import Foundation

public enum InputDescriptorEvaluation: CustomDebugStringConvertible {
  case candidateClaim(matches: [Field: CandidateField])
  case notMatchingClaim
  case notMatchedFieldConstraints
  case unsupportedFormat

  // swiftlint:disable line_length
  public var debugDescription: String {
    switch self {
    case .candidateClaim(matches: let matches):
      return "Matched \(matches.map {($0.key, $0.value)}.enumerated().map { "Field no:\($0) was matched \($1.1.debugDescription)"})"
    case .notMatchingClaim:
      return "Not matched"
    case .notMatchedFieldConstraints:
      return "Not matched field constraints"
    case .unsupportedFormat:
      return "Unsupported format"
    }
  }
  // swiftlint:enable line_length
}

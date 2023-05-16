import Foundation

public enum InputDescriptorEvaluation {
  case candidateClaim(matches: [Field: CandidateField])
  case notMatchingClaim
  case notMatchedFieldConstraints
  case unsupportedFormat
}

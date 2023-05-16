import Foundation

public enum Match {
  case matched(matches: InputDescriptorEvaluationPerClaim)
  case notMatched(details: InputDescriptorEvaluationPerClaim)
  
  public func debug() {
    switch self {
    case .matched(matches: let matches):
      print("Matched presentation definition.")
      matches.forEach { (key: InputDescriptorId, value: [ClaimId : InputDescriptorEvaluation]) in
        print("Input descriptor: \(key)")
        value.forEach { (key: ClaimId, value: InputDescriptorEvaluation) in
          print("Claim \(key) \(value)")
        }
      }
    case .notMatched(details: let details):
      details.forEach { (key: InputDescriptorId, value: [ClaimId : InputDescriptorEvaluation]) in
        
      }
    }
  }
}

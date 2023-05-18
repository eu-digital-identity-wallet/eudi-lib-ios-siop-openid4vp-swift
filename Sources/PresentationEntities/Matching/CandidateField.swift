import Foundation

public enum CandidateField: Equatable, CustomDebugStringConvertible {
  case requiredFieldNotFound
  case optionalFieldNotFound
  case found(path: JSONPath, content: String)
  case predicateEvaluated(path: JSONPath, predicateEvaluation: Bool)

  public var debugDescription: String {
    switch self {
    case .requiredFieldNotFound:
      return "required not present"
    case .optionalFieldNotFound:
      return "not present but was optional"
    case .found(let path, let content):
      return "in path \(path) with content \(content)"
    case .predicateEvaluated(let path, let predicateEvaluation):
      return "in path \(path) predicated evaluated to \(predicateEvaluation)"
    }
  }
}

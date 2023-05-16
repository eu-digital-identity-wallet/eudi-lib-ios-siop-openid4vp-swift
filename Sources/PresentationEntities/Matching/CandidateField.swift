import Foundation

public enum CandidateField: Equatable {
  case requiredFieldNotFound
  case optionalFieldNotFound
  case found(path: JSONPath, content: String)
  case predicateEvaluated(path: JSONPath, predicateEvaluation: Bool)
}

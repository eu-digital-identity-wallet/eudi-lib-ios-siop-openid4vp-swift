import Foundation

public enum IdTokenType: String, Codable {
  case subjectSigned = "subject_signed"
  case attesterSigned = "attester_signed"
}

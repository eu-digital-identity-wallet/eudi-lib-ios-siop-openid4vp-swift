import Foundation

public struct SubmissionRequirements: Codable {
  public let rule: Rule
  public let count: Int?
  public let min: Int?
  public let max: Int?
  public let from: Group?
  public let fromNested: [SubmissionRequirements]?
  public let name: Name?
  public let purpose: Purpose?

  enum CodingKeys: String, CodingKey {
    case rule
    case count
    case min
    case max
    case from
    case name
    case purpose
    case fromNested = "from_nested"
  }

  init(
    rule: Rule,
    count: Int?,
    min: Int?,
    max: Int?,
    from: Group?,
    fromNested: [SubmissionRequirements]?,
    name: Name?,
    purpose: Purpose?
  ) {
    self.rule = rule
    self.count = count
    self.min = min
    self.max = max
    self.from = from
    self.fromNested = fromNested
    self.name = name
    self.purpose = purpose
  }
}

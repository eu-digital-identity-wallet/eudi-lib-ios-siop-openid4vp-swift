import Foundation

public struct Claim {
  public let id: ClaimId
  public let format: FormatDesignation
  public let jsonObject: JSONObject

  public init(
    id: ClaimId,
    format: FormatDesignation,
    jsonObject: JSONObject
  ) {
    self.id = id
    self.format = format
    self.jsonObject = jsonObject
  }
}

import Foundation

public struct Claim {
  public let id: ClaimId
  public let format: ClaimFormat
  public let jsonObject: JSONObject

  public init(
    id: ClaimId,
    format: ClaimFormat,
    jsonObject: JSONObject
  ) {
    self.id = id
    self.format = format
    self.jsonObject = jsonObject
  }
}

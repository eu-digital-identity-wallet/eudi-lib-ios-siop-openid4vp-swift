import Foundation

public struct Claim {
  public let id: ClaimId
  public let jsonObject: JSONObject

  public init(id: ClaimId, jsonObject: JSONObject) {
    self.id = id
    self.jsonObject = jsonObject
  }
}

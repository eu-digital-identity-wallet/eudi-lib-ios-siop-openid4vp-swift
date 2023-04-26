import Foundation

public struct Claim {
  let id: ClaimId
  let jsonObject: JSONObject

  public init(id: ClaimId, jsonObject: JSONObject) {
    self.id = id
    self.jsonObject = jsonObject
  }
}

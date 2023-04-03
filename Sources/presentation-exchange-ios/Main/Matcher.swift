import Foundation
import Sextant

struct Claim {
  let id: ClaimId
  let jsonObject: JSONObject
}

protocol PresentationMatching {
  func match(pd: PresentationDefinition, claims: [Claim]) -> Match
}

class PresentationMatcher: PresentationMatching {
  func match(pd: PresentationDefinition, claims: [Claim]) -> Match {
    var match: Match = [:]
    let inputDescriptors = pd.inputDescriptors
    claims.forEach { claim in
      inputDescriptors.forEach { descriptor in
        let constraints = descriptor.constraints
        var result: [(String, Any)] = []
        constraints.fields.forEach { field in
          
          let queries = field.path
          let json = claim.jsonObject.toJSONString()
          
          let values = json?.query(values: queries)
          let paths = json?.query(paths: queries)
          
          if let path = paths?.first as? String,
             let value = values?.first as? String {
            result.append((path, value))
          }
        }
        if !result.isEmpty {
          match[claim.id] = result
        }
      }
    }
    return match
  }
}

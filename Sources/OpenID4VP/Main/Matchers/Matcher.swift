import Foundation
import Sextant

public enum ClaimsEvaluation {
  case found(Match)
  case notFound
}

public protocol PresentationMatching {
  func match(presentationDefinition: PresentationDefinition, claims: [Claim]) -> ClaimsEvaluation
}

public class PresentationMatcher: PresentationMatching {
  public func match(presentationDefinition: PresentationDefinition, claims: [Claim]) -> ClaimsEvaluation {
    var match: Match = [:]
    claims.forEach { claim in
      let matches = presentationDefinition.inputDescriptors.map { descriptor in
        let matches = self.match(claim: claim, with: descriptor)
        return [descriptor.id: matches]
      }
      match[claim.id] = matches
    }
    /*
    if match.count != pd.inputDescriptors.count {
      return .notFound
    }
     */
    return .found(match)
  }

  private func match(claim: Claim, with descriptor: InputDescriptor) -> [(String, Any)] {
    var result: [(String, Any)] = []
    descriptor.constraints.fields.forEach { field in
      field.paths.forEach { query in
        let json = claim.jsonObject.toJSONString()
        if let values = json?.query(values: query)?.compactMap({ $0 }),
           !values.isEmpty {
          result.append((query, values))
        }
      }
    }
    return result
  }
}

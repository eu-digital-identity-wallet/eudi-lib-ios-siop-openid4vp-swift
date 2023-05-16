import Foundation
import Sextant
import JSONSchema

public typealias ClaimsEvaluation = [ClaimId: [InputDescriptorId: InputDescriptorEvaluation]]
typealias InputDescriptorEvaluationPerClaim = [InputDescriptorId: [ClaimId: InputDescriptorEvaluation]]

public enum MatchEvaluation {
  case found(Match)
  case notFound
}

public protocol PresentationMatcherType {
  func match(presentationDefinition: PresentationDefinition, claims: [Claim]) -> MatchEvaluation
}

public class PresentationMatcher: PresentationMatcherType {
  public func match(presentationDefinition: PresentationDefinition, claims: [Claim]) -> MatchEvaluation {
    var match: Match = [:]
    claims.forEach { claim in
      let matches = presentationDefinition.inputDescriptors.compactMap { descriptor in
        let matches = self.match(claim: claim, with: descriptor)
        return matches.isEmpty ? nil : [descriptor.id: matches]
      }
      if !matches.isEmpty {
        match[claim.id] = matches
      }
    }
    return match.isEmpty ? .notFound : .found(match)
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

  public func match(claims: [Claim], with definition: PresentationDefinition) -> ClaimsEvaluation {
    let claimsEvaluation = claims.associate { claim in
      (
        claim.id,
        matchInputDescriptors(
          presentationDefinitionFormat: definition.format,
          inputDescriptors: definition.inputDescriptors,
          claim: claim
        )
      )
    }

    let (candidateClaims, notMatchingClaims) = splitPerDescriptor(
      presentationDefinition: definition,
      claimsEvaluation: claimsEvaluation
    )

    return claimsEvaluation
  }
}

private extension PresentationMatcher {
  private func matchInputDescriptors(
    presentationDefinitionFormat: Format?,
    inputDescriptors: [InputDescriptor],
    claim: Claim
  ) -> [InputDescriptorId: InputDescriptorEvaluation] {
    inputDescriptors.associate {
      (
        $0.id,
        evaluate(
          presentationDefinitionFormat: presentationDefinitionFormat,
          inputDescriptor: $0,
          claim: claim
        )
      )
    }
  }

  private func evaluate(
    presentationDefinitionFormat: Format?,
    inputDescriptor: InputDescriptor,
    claim: Claim
  ) -> InputDescriptorEvaluation {
    let supportedFormat = isFormatSupported(
      inputDescriptor: inputDescriptor,
      presentationDefinitionFormat: presentationDefinitionFormat,
      claimFormat: claim.format
    )

    return !supportedFormat
    ? .unsupportedFormat
    : checkFieldConstraints(
      fieldConstraints: inputDescriptor.constraints.fields,
      claim: claim
    )
  }

  private func isFormatSupported(
    inputDescriptor: InputDescriptor,
    presentationDefinitionFormat: Format?,
    claimFormat: ClaimFormat
  ) -> Bool {
    return true
  }

  private func checkFieldConstraints(
    fieldConstraints: [Field],
    claim: Claim
  ) -> InputDescriptorEvaluation {

    let matchedResults: [Field: CandidateField] =
    fieldConstraints.associateWith { field in
      match(claim: claim, with: field)
    }

    let notMatchedResults = matchedResults.filterValues { field in
      field == .requiredFieldNotFound
    }.keys

    return !notMatchedResults.isEmpty
    ? .notMatchedFieldConstraints
    : .candidateClaim(matches: matchedResults)
  }

  private func match(
    claim: Claim,
    with field: Field
  ) -> CandidateField {
    for path in field.paths {
      let json = claim.jsonObject.toJSONString()
      if let values = json?.query(values: path)?.compactMap({ $0 }),
         let value = values.first as? String,
         filter(
          value: value,
          with: field.filter
         ) {
        return .found(path: path, content: value)
      }
    }
    return field.optional == true ? .optionalFieldNotFound : .requiredFieldNotFound
  }

  private func filter(
    value: String,
    with filter: Filter?
  ) -> Bool {
    guard let filter = filter else {
      return true
    }

    if let date = filter["format"] as? String, date == "date" {
      return true
    }

    do {
      let result = try JSONSchema.validate(value, schema: filter)
      return result.valid

    } catch {
      return false
    }
  }

  private func splitPerDescriptor(
    presentationDefinition: PresentationDefinition,
    claimsEvaluation: ClaimsEvaluation
  ) -> (
    candidateClaims: InputDescriptorEvaluationPerClaim,
    notMatchingClaims: InputDescriptorEvaluationPerClaim
  ) {

    var candidateClaimsPerDescriptor: [InputDescriptorId: [ClaimId: InputDescriptorEvaluation]] = [:]
    var notMatchingClaimsPerDescriptor: [InputDescriptorId: [ClaimId: InputDescriptorEvaluation]] = [:]

    func updateCandidateClaims(inputDescriptor: InputDescriptor) {
      let candidateClaims = claimsEvaluation.mapValues { element in
        element[inputDescriptor.id]
      }.filter {
        guard let value = $0.value else {
          return false
        }
        switch value {
        case .candidateClaim:
          return true
        default: return false
        }
      }
      .compactMapValues { $0 }

      if !candidateClaims.isEmpty {
        candidateClaimsPerDescriptor[inputDescriptor.id] = candidateClaims
      }
    }

    func updateNotMatchingClaims(inputDescriptor: InputDescriptor) {
      let candidateClaims = claimsEvaluation.mapValues { element in
        element[inputDescriptor.id]
      }.filter {
        guard let value = $0.value else {
          return false
        }
        switch value {
        case .notMatchedFieldConstraints:
          return true
        default: return false
        }
      }
      .compactMapValues { $0 }

      if !candidateClaims.isEmpty {
        notMatchingClaimsPerDescriptor[inputDescriptor.id] = candidateClaims
      }
    }

    for inputDescriptor in presentationDefinition.inputDescriptors {
      updateCandidateClaims(inputDescriptor: inputDescriptor)
      updateNotMatchingClaims(inputDescriptor: inputDescriptor)
    }

    return (candidateClaimsPerDescriptor, notMatchingClaimsPerDescriptor)
  }
}

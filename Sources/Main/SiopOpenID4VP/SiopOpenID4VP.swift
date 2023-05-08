import Foundation

public protocol SiopOpenID4VPProtocol {
  func process(url: URL) async throws -> PresentationDefinition
  func match(presentationDefinition: PresentationDefinition, claims: [Claim]) -> ClaimsEvaluation
  func submit()
}

public class SiopOpenID4VP {

  public init() {}
  public func process(url: URL) async throws -> PresentationDefinition {
    throw ValidatedAuthorizationError.noAuthorizationData
  }

  public func match(presentationDefinition: PresentationDefinition, claims: [Claim]) -> ClaimsEvaluation {
    return .notFound
  }

  public func submit() {}
}

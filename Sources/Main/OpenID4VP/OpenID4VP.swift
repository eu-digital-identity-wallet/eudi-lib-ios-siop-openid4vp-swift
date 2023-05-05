import Foundation

/**
 OpenID for Verifiable Presentations

 - Requesting and presenting Verifiable Credentials
   Reference: https://openid.net/specs/openid-4-verifiable-presentations-1_0.html
 
 */

public protocol OpenID4VPProtocol {
  func process(url: URL) async throws -> PresentationDefinition
  func match(presentationDefinition: PresentationDefinition, claims: [Claim]) -> ClaimsEvaluation
  func submit()
}

public class OpenID4VP {

  public init() {}

  /**
   Processes an authorisation URL.
   
   - Reference: https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-authorization-request

   - Parameters:
      - url: A valid URL

   - Returns: A PresentationDefinition object
   
   - Throws: An error if it cannot resolve a presentation definition
   */
  public func process(url: URL) async throws -> PresentationDefinition {
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: url)

    let validAuthorizationData = try ValidatedAuthorizationRequestData(
      authorizationRequestData: authorizationRequestData
    )

    guard let presentationDefinitionSource = validAuthorizationData.presentationDefinitionSource else {
      throw ValidatedAuthorizationError.noAuthorizationData
    }

    let resolvedValidAuthorizationData = try await ResolvedAuthorizationRequestData(
      resolver: PresentationDefinitionResolver(),
      source: presentationDefinitionSource
    )

    return resolvedValidAuthorizationData.presentationDefinition
  }

  /**
   Matches a presentation definition to a list of claims.

   - Parameters:
    - presentationDefinition: A valid URL
    - claims: A list of claim objects

   - Returns: A ClaimsEvaluation object, empty or with matches
   */
  public func match(presentationDefinition: PresentationDefinition, claims: [Claim]) -> ClaimsEvaluation {
    let matcher = PresentationMatcher()
    return matcher.match(presentationDefinition: presentationDefinition, claims: claims)
  }

  /**
   WIP: Submits a request
   */
  public func submit() {}
}

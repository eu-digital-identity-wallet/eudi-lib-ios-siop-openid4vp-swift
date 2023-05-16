import Foundation

/**
 OpenID for Verifiable Presentations

 - Requesting and presenting Verifiable Credentials
   Reference: https://openid.net/specs/openid-4-verifiable-presentations-1_0.html
 
 */
public protocol SiopOpenID4VPType {
  func process(url: URL) async throws -> PresentationDefinition
  func process(request: JSONObject) async throws -> PresentationDefinition
  func match(presentationDefinition: PresentationDefinition, claims: [Claim]) -> MatchEvaluation
  func submit()
}

public class SiopOpenID4VP {

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

    let authorizationRequest = try await AuthorizationRequest(authorizationRequestData: authorizationRequestData)

    switch authorizationRequest {
    case .jwt(request: let data):
      switch data {
      case .idToken:
        throw ValidatedAuthorizationError.unsupportedResponseType(".idToken")
      case .vpToken(let request):
        return request.presentationDefinition
      case .idAndVpToken(let request):
        return request.presentationDefinition
      }
    case .oauth2(let data):
      switch data {
      case .idToken:
        throw ValidatedAuthorizationError.unsupportedResponseType(".idToken")
      case .vpToken(let request):
        return request.presentationDefinition
      case .idAndVpToken(let request):
        return request.presentationDefinition
      }
    }
  }

  func process(request: JSONObject) async throws -> PresentationDefinition {
    throw ValidatedAuthorizationError.invalidRequest
  }

  /**
   Matches a presentation definition to a list of claims.

   - Parameters:
    - presentationDefinition: A valid URL
    - claims: A list of claim objects

   - Returns: A ClaimsEvaluation object, empty or with matches
   */
  public func match(presentationDefinition: PresentationDefinition, claims: [Claim]) -> MatchEvaluation {
    return .notFound
  }

  /**
   WIP: Submits a request
   */
  public func submit() {}
}

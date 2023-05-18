import Foundation

/**
 OpenID for Verifiable Presentations

 - Requesting and presenting Verifiable Credentials
   Reference: https://openid.net/specs/openid-4-verifiable-presentations-1_0.html
 
 */
public protocol SiopOpenID4VPType {
  func process(url: URL) async throws -> PresentationDefinition
  func process(request: JSONObject) async throws -> PresentationDefinition
  func match(presentationDefinition: PresentationDefinition, claims: [Claim]) -> Match
  func submit()
  func consent()
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

  public func authorization(url: URL) async throws -> AuthorizationRequest {
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: url)

    return try await AuthorizationRequest(authorizationRequestData: authorizationRequestData)
  }

  /**
   Matches a presentation definition to a list of claims.

   - Parameters:
    - presentationDefinition: A valid URL
    - claims: A list of claim objects

   - Returns: A ClaimsEvaluation object, empty or with matches
   */
  public func match(presentationDefinition: PresentationDefinition, claims: [Claim]) -> Match {
    let matcher = PresentationMatcher()
    return matcher.match(claims: claims, with: presentationDefinition)
  }

  /**
   WIP: Consent to matches
   */
  func consent() {}

  /**
   WIP: Submits a request
   */
  public func submit() {}
}

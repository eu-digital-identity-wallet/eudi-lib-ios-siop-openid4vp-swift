import Foundation
import Combine
@_exported import PresentationExchange

/**
 OpenID for Verifiable Presentations

 - Requesting and presenting Verifiable Credentials
   Reference: https://openid.net/specs/openid-4-verifiable-presentations-1_0.html
 
 */
public protocol SiopOpenID4VPType {
  func process(url: URL) async throws -> PresentationDefinition
  func process(request: JSONObject) async throws -> PresentationDefinition
  func authorize(url: URL) async throws -> AuthorizationRequest
  func authorizationPublisher(for url: URL) -> AnyPublisher<AuthorizationRequest, Error>
  func match(presentationDefinition: PresentationDefinition, claims: [Claim]) -> Match
  func dispatch(response: AuthorizationRequest) async throws -> DispatchOutcome
  func submit()
  func consent()
}

public class SiopOpenID4VP {

  public init() {
    registerDependencies()
  }

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

  public func authorize(url: URL) async throws -> AuthorizationRequest {
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: url)

    return try await AuthorizationRequest(authorizationRequestData: authorizationRequestData)
  }

  public func authorizationPublisher(for url: URL) -> AnyPublisher<AuthorizationRequest, Error> {
    Future<AuthorizationRequest, Error> { promise in
      Task {
        do {
          let authorizationRequestData = AuthorizationRequestUnprocessedData(from: url)
          let result =  try await AuthorizationRequest(authorizationRequestData: authorizationRequestData)
          promise(.success(result))
        } catch {
          promise(.failure(error))
        }
      }
    }
    .eraseToAnyPublisher()
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
   Dispatches an autorisation request.

   - Parameters:
    - response: An AuthorizationRequest

   - Returns: A DispatchOutcome enum
   */
  func dispatch(response: AuthorizationRequest) async throws -> DispatchOutcome {
    .none
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

private extension SiopOpenID4VP {
  func registerDependencies() {
    DependencyContainer.shared.register(type: Reporting.self, dependency: {
      Reporter()
    })
  }
}

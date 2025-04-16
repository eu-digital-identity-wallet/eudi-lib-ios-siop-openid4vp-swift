/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import Foundation
@_exported import PresentationExchange

/**
 OpenID for Verifiable Presentations

 - Requesting and presenting Verifiable Credentials
   Reference: https://openid.net/specs/openid-4-verifiable-presentations-1_0.html
 
 */
public protocol SiopOpenID4VPType {
  func process(url: URL) async throws -> PresentationDefinition
  func authorize(url: URL) async throws -> AuthorizationRequest
  func match(presentationDefinition: PresentationDefinition, claims: [Claim]) -> Match
  func dispatch(response: AuthorizationResponse) async throws -> DispatchOutcome
  func submit()
  func consent()
}

public class SiopOpenID4VP: SiopOpenID4VPType {

  let walletConfiguration: SiopOpenId4VPConfiguration?

  public init(walletConfiguration: SiopOpenId4VPConfiguration? = nil) {
    self.walletConfiguration = walletConfiguration
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
    let authorizationRequestData = UnvalidatedRequestObject(from: url)

    let authorizationRequest = try await AuthorizationRequest(
      authorizationRequestData: authorizationRequestData,
      walletConfiguration: walletConfiguration
    )

    switch authorizationRequest {
    case .jwt(request: let data):
      switch data {
      case .idToken:
        throw ValidationError.unsupportedResponseType(".idToken")
      case .vpToken(let request):
        switch request.presentationQuery {
        case .byPresentationDefinition(let presentationDefinition):
          return presentationDefinition
        case .byDigitalCredentialsQuery(_):
          throw ValidationError.validationError("Insupported presentation query")
        }
      case .idAndVpToken(let request):
        return request.presentationDefinition
      }
    case .notSecured(let data):
      switch data {
      case .idToken:
        throw ValidationError.unsupportedResponseType(".idToken")
      case .vpToken(let request):
        switch request.presentationQuery {
        case .byPresentationDefinition(let presentationDefinition):
          return presentationDefinition
        case .byDigitalCredentialsQuery(_):
          throw ValidationError.validationError("Insupported presentation query")
        }
      case .idAndVpToken(let request):
        return request.presentationDefinition
      }
    case .invalidResolution:
      throw ValidationError.validationError("Invalid resolution")
    }
  }

  public func authorize(url: URL) async throws -> AuthorizationRequest {
    try await .init(
      authorizationRequestData: .init(from: url),
      walletConfiguration: walletConfiguration
    )
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
    - response: An AuthorizationResponse

   - Returns: A DispatchOutcome enum
   */
  public func dispatch(response: AuthorizationResponse) async throws -> DispatchOutcome {

    let dispatcher = Dispatcher(
      authorizationResponse: response
    )

    return try await dispatcher.dispatch(
      poster: Poster(
        session: walletConfiguration?.session ?? URLSession.shared
      )
    )
  }

  /**
   Dispatches an autorisation request.

   - Parameters:
    - response: An AuthorizationResponse

   - Returns: A DispatchOutcome enum
   */
  public func dispatch(
    error: AuthorizationRequestError,
    details: ErrorDispatchDetails?
  ) async throws -> DispatchOutcome {

    let dispatcher = ErrorDispatcher(
      error: error,
      details: details
    )

    return try await dispatcher.dispatch(
      poster: Poster(
        session: walletConfiguration?.session ?? URLSession.shared
      )
    )
  }
  
  /**
   WIP: Consent to matches
   */
  public func consent() {}

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

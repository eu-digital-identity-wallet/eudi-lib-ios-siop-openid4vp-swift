import Foundation
import PresentationExchange

/// An enumeration representing different types of authorization requests.
public enum AuthorizationRequest {
  /// An OAuth2 authorization request.
  case oauth2(data: ResolvedSiopOpenId4VPRequestData)

  /// A JWT authorization request.
  case jwt(request: ResolvedSiopOpenId4VPRequestData)
}

/// An extension providing an initializer for the `AuthorizationRequest` enumeration.
public extension AuthorizationRequest {
  /// Initializes an `AuthorizationRequest` using the provided authorization request data.
  /// - Parameters:
  ///   - authorizationRequestData: The authorization request data to process.
  init(authorizationRequestData: AuthorizationRequestUnprocessedData?) async throws {
    guard let authorizationRequestData = authorizationRequestData else {
      throw ValidatedAuthorizationError.noAuthorizationData
    }

    guard !authorizationRequestData.hasConflicts else {
      throw ValidatedAuthorizationError.conflictingData
    }

    if let request = authorizationRequestData.request {
      let validatedAuthorizationRequestData = try ValidatedSiopOpenId4VPRequest(request: request)

      let resolvedSiopOpenId4VPRequestData = try await ResolvedSiopOpenId4VPRequestData(
        clientMetaDataResolver: ClientMetaDataResolver(),
        presentationDefinitionResolver: PresentationDefinitionResolver(),
        validatedAuthorizationRequest: validatedAuthorizationRequestData
      )
      self = .jwt(request: resolvedSiopOpenId4VPRequestData)
    } else if let requestUri = authorizationRequestData.requestUri {
      let validatedAuthorizationRequestData = try await ValidatedSiopOpenId4VPRequest(requestUri: requestUri)

      let resolvedSiopOpenId4VPRequestData = try await ResolvedSiopOpenId4VPRequestData(
        clientMetaDataResolver: ClientMetaDataResolver(),
        presentationDefinitionResolver: PresentationDefinitionResolver(),
        validatedAuthorizationRequest: validatedAuthorizationRequestData
      )
      self = .jwt(request: resolvedSiopOpenId4VPRequestData)
    } else {
      let validatedAuthorizationRequestData = try await ValidatedSiopOpenId4VPRequest(
        authorizationRequestData: authorizationRequestData
      )

      let resolvedSiopOpenId4VPRequestData = try await ResolvedSiopOpenId4VPRequestData(
        clientMetaDataResolver: ClientMetaDataResolver(),
        presentationDefinitionResolver: PresentationDefinitionResolver(),
        validatedAuthorizationRequest: validatedAuthorizationRequestData
      )

      self = .oauth2(data: resolvedSiopOpenId4VPRequestData)
    }
  }
}

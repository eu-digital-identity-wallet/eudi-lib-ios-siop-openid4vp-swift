import Foundation

public enum AuthorizationRequest {
  case oauth2(data: ResolvedSiopOpenId4VPRequestData)
  case jwt(request: ResolvedSiopOpenId4VPRequestData)
}

public extension AuthorizationRequest {
  init(authorizationRequestData: AuthorizationRequestUnprocessedData?) async throws {

    guard
      let authorizationRequestData = authorizationRequestData
    else {
      throw ValidatedAuthorizationError.noAuthorizationData
    }

    guard
      !authorizationRequestData.hasConflicts
    else {
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

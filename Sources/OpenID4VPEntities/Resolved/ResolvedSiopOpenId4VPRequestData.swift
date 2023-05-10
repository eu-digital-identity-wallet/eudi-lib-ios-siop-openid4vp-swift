import Foundation

public enum ResolvedSiopOpenId4VPRequestData {
  case idToken(request: IdTokenData)
  case vpToken(request: VpTokenData)
  case idAndVpToken(request: IdAndVpTokenData)
}

public extension ResolvedSiopOpenId4VPRequestData {
  // swiftlint:disable function_body_length
  init(
    clientMetaDataResolver: ClientMetaDataResolver,
    presentationDefinitionResolver: PresentationDefinitionResolver,
    validatedAuthorizationRequest: ValidatedSiopOpenId4VPRequest
  ) async throws {
    switch validatedAuthorizationRequest {
    case .idToken(request: let request):
      guard
        let clientMetaDataSource = request.clientMetaDataSource,
        let clientMetaData = try? await clientMetaDataResolver.resolve(source: clientMetaDataSource).get()
      else {
        throw ResolvedAuthorisationError.invalidClientData
      }

      self = .idToken(request: .init(
        idTokenType: request.idTokenType,
        clientMetaData: clientMetaData,
        clientId: request.clientId,
        nonce: request.nonce,
        responseMode: request.responseMode,
        state: request.state,
        scope: request.scope
      ))
    case .vpToken(request: let request):
      guard
        let clientMetaDataSource = request.clientMetaDataSource,
        let clientMetaData = try? await clientMetaDataResolver.resolve(source: clientMetaDataSource).get()
      else {
        throw ResolvedAuthorisationError.invalidClientData
      }

      guard
        let presentationDefinition = try? await presentationDefinitionResolver.resolve(
          source: request.presentationDefinitionSource
        ).get()
      else {
        throw ResolvedAuthorisationError.invalidClientData
      }

      self = .vpToken(request: .init(
        presentationDefinition: presentationDefinition,
        clientMetaData: clientMetaData,
        clientId: request.clientId,
        nonce: request.nonce,
        responseMode: request.responseMode,
        state: request.state
      ))
    case .idAndVpToken(request: let request):
      guard
        let clientMetaDataSource = request.clientMetaDataSource,
        let clientMetaData = try? await clientMetaDataResolver.resolve(source: clientMetaDataSource).get()
      else {
        throw ResolvedAuthorisationError.invalidClientData
      }

      guard
        let presentationDefinition = try? await presentationDefinitionResolver.resolve(
          source: request.presentationDefinitionSource
        ).get()
      else {
        throw ResolvedAuthorisationError.invalidClientData
      }

      self = .idAndVpToken(request: .init(
        idTokenType: request.idTokenType,
        presentationDefinition: presentationDefinition,
        clientMetaData: clientMetaData,
        clientId: request.clientId,
        nonce: request.nonce,
        responseMode: request.responseMode,
        state: request.state,
        scope: request.scope
      ))
    }
  }
  // swiftlint:enable function_body_length
}

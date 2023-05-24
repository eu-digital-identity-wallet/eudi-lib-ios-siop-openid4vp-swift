import Foundation
import PresentationExchange

public struct ResolvedAuthorizationRequestData {
  public let presentationDefinition: PresentationDefinition
  public let clientMetaData: ClientMetaData?
  public let nonce: Nonce?
  public let responseMode: ResponseMode?
}

public extension ResolvedAuthorizationRequestData {
  init(
    resolver: PresentationDefinitionResolver,
    source: PresentationDefinitionSource,
    predefinedDefinitions: [String: PresentationDefinition] = [:],
    clientMetaData: ClientMetaData? = nil,
    nonce: Nonce? = nil,
    responseMode: ResponseMode? = nil
  ) async throws {
    presentationDefinition = try await resolver.resolve(
      predefinedDefinitions: predefinedDefinitions,
      source: source
    ).get()

    self.clientMetaData = clientMetaData
    self.nonce = nonce
    self.responseMode = responseMode
  }
}

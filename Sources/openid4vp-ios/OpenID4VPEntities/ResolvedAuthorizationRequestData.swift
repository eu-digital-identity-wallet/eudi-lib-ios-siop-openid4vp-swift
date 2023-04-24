import Foundation

public struct ResolvedAuthorizationRequestData {
  public let presentationDefinition: PresentationDefinition
  public let clientMetaData: ClientMetaData? = nil
  public let nonce: Nonce? = nil
  public let responseMode: ResponseMode? = nil
}

public extension ResolvedAuthorizationRequestData {
  init(
    resolver: PresentationDefinitionResolver,
    source: PresentationDefinitionSource,
    predefinedDefinitions: Dictionary<String, PresentationDefinition> = [:]
  ) async throws {
    presentationDefinition = try await resolver.resolve(
      predefinedDefinitions: predefinedDefinitions,
      source: source
    ).get()
  }
}

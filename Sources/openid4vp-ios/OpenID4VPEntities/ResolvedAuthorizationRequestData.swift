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
    source: PresentationDefinitionSource
  ) throws {
    presentationDefinition = try resolver.resolve(source: source).get()
  }
}

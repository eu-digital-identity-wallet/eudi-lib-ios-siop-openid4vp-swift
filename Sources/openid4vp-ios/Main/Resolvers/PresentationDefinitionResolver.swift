import Foundation

public class PresentationDefinitionResolver: Resolving {
  public func resolve(
    fetcher: Fetcher<PresentationDefinition> = Fetcher(),
    predefinedDefinitions: Dictionary<String, PresentationDefinition> = [:],
    source: PresentationDefinitionSource
  ) async -> Result<PresentationDefinition, ResolvingError> {
    switch source {
    case .passByValue(presentationDefinition: let presentationDefinition):
      return .success(presentationDefinition)
    case .fetchByReference(url: let url):
      let result = await fetcher.fetch(url: url)
      let presentationDefinition = try? result.get()
      if let presentationDefinition = presentationDefinition {
        return .success(presentationDefinition)
      }
      return .failure(.invalidSource)
    case .scopes(scopes: let list):
      if let definition = predefinedDefinitions.first(where: { list.contains($0.key)}) {
        return .success(definition.value)
      }
      return .failure(.invalidSource)
    }
  }
}

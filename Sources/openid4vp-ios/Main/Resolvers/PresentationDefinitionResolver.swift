import Foundation

public class PresentationDefinitionResolver: Resolving {
  public typealias InputType = PresentationDefinitionSource
  public typealias OutputType = PresentationDefinition
  
  public func resolve(
    predefinedDefinitions: Dictionary<String, PresentationDefinition> = [:],
    source: PresentationDefinitionSource
  ) -> Result<OutputType, ResolvingError> {
    switch source {
    case .passByValue(presentationDefinition: let presentationDefinition):
      return .success(presentationDefinition)
    case .fetchByReference(url: _):
      return .failure(.invalidSource)
    case .scopes(scopes: let list):
      if let definition = predefinedDefinitions.first(where: { list.contains($0.key)}) {
        return .success(definition.value)
      }
      return .failure(.invalidSource)
    }
  }
}

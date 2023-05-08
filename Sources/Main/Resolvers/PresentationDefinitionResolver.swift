import Foundation

public protocol PresentationDefinitionResolving {
  associatedtype InputType
  associatedtype OutputType: Codable
  associatedtype ErrorType: Error
  func resolve(
    fetcher: Fetcher<OutputType>,
    predefinedDefinitions: [String: OutputType],
    source: InputType
  ) async -> Result<OutputType, ErrorType>
}

public class PresentationDefinitionResolver: PresentationDefinitionResolving {
  public func resolve(
    fetcher: Fetcher<PresentationDefinition> = Fetcher(),
    predefinedDefinitions: [String: PresentationDefinition] = [:],
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
    case .implied(scope: let list):
      if let definition = predefinedDefinitions.first(where: { list.contains($0.key)}) {
        return .success(definition.value)
      }
      return .failure(.invalidScopes)
    }
  }
}

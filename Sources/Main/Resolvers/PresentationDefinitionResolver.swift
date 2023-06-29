import Foundation
import PresentationExchange

public protocol PresentationDefinitionResolverType {
  /// The input type for resolving presentation definitions.
  associatedtype InputType

  /// The output type for resolved presentation definitions. Must be Codable.
  associatedtype OutputType: Codable

  /// The error type for resolving presentation definitions. Must conform to the Error protocol.
  associatedtype ErrorType: Error

  /// Resolves presentation definitions asynchronously.
  ///
  /// - Parameters:
  ///   - fetcher: The fetcher object responsible for fetching presentation definitions.
  ///   - predefinedDefinitions: Predefined presentation definitions mapped by keys.
  ///   - source: The input source for resolving presentation definitions.
  /// - Returns: An asynchronous result containing the resolved presentation definition or an error.
  func resolve(
    fetcher: Fetcher<OutputType>,
    predefinedDefinitions: [String: OutputType],
    source: InputType
  ) async -> Result<OutputType, ErrorType>
}

public actor PresentationDefinitionResolver: PresentationDefinitionResolverType {
  /// Resolves presentation definitions asynchronously.
  ///
  /// - Parameters:
  ///   - fetcher: The fetcher object responsible for fetching presentation definitions.
  ///   - predefinedDefinitions: Predefined presentation definitions mapped by keys.
  ///   - source: The input source for resolving presentation definitions.
  /// - Returns: An asynchronous result containing the resolved presentation definition or an error
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

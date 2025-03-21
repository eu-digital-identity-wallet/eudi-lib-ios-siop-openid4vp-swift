/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import Foundation
import PresentationExchange

public protocol PresentationDefinitionResolverType {
  /// The input type for resolving presentation definitions.
  associatedtype InputType: Sendable

  /// The output type for resolved presentation definitions. Must be Codable.
  associatedtype OutputType: Codable, Sendable

  /// The error type for resolving presentation definitions. Must conform to the Error protocol.
  associatedtype ErrorType: Error

  /// Resolves presentation definitions asynchronously.
  ///
  /// - Parameters:
  ///   - predefinedDefinitions: Predefined presentation definitions mapped by keys.
  ///   - source: The input source for resolving presentation definitions.
  /// - Returns: An asynchronous result containing the resolved presentation definition or an error.
  func resolve(
    predefinedDefinitions: [String: OutputType],
    source: InputType
  ) async -> Result<OutputType, ErrorType>
}

public actor PresentationDefinitionResolver: PresentationDefinitionResolverType {

  private let fetcher: Fetcher<PresentationDefinition>

  /**
    Initializes an instance.
   */
  public init(
    fetcher: Fetcher<PresentationDefinition> = Fetcher()
  ) {
    self.fetcher = fetcher
  }

  /// Resolves presentation definitions asynchronously.
  ///
  /// - Parameters:
  ///   - predefinedDefinitions: Predefined presentation definitions mapped by keys.
  ///   - source: The input source for resolving presentation definitions.
  /// - Returns: An asynchronous result containing the resolved presentation definition or an error
  public func resolve(
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

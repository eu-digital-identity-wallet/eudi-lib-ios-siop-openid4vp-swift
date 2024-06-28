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

public protocol ClientMetaDataResolverType {
  /// The input type for resolving client metadata.
  associatedtype InputType

  /// The output type for resolved client metadata. Must be Codable and Equatable.
  associatedtype OutputType: Codable, Equatable

  /// The error type for resolving client metadata. Must conform to the Error protocol.
  associatedtype ErrorType: Error

  /// Resolves client metadata asynchronously.
  ///
  /// - Parameters:
  ///   - fetcher: The fetcher object responsible for fetching metadata.
  ///   - source: The input source for resolving metadata.
  /// - Returns: An asynchronous result containing the resolved metadata or an error.
  func resolve(
    fetcher: Fetcher<OutputType>,
    source: InputType?
  ) async -> Result<OutputType?, ErrorType>
}

public actor ClientMetaDataResolver: ClientMetaDataResolverType {

  /**
    Initializes an instance.
   */
  public init() {
  }

  /// Resolves client metadata asynchronously.
  ///
  /// - Parameters:
  ///   - fetcher: The fetcher object responsible for fetching metadata. Default value is Fetcher<ClientMetaData>().
  ///   - source: The input source for resolving metadata.
  /// - Returns: An asynchronous result containing the resolved metadata or an error of type ResolvingError.
  public func resolve(
    fetcher: Fetcher<ClientMetaData> = Fetcher(),
    source: ClientMetaDataSource?
  ) async -> Result<ClientMetaData?, ResolvingError> {
    guard let source = source else { return .success(nil) }
    switch source {
    case .passByValue(metaData: let metaData):
      return .success(metaData)
    case .fetchByReference(url: let url):
      let result = await fetcher.fetch(url: url)
      let metaData = try? result.get()
      if let metaData = metaData {
        return .success(metaData)
      }
      return .failure(.invalidSource)
    }
  }
}

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
  associatedtype InputType: Sendable

  /// The output type for resolved client metadata. Must be Codable and Equatable.
  associatedtype OutputType: Codable, Sendable

  /// The error type for resolving client metadata. Must conform to the Error protocol.
  associatedtype ErrorType: Error

  /// Resolves client metadata asynchronously.
  ///
  /// - Parameters:
  ///   - source: The input source for resolving metadata.
  /// - Returns: An asynchronous result containing the resolved metadata or an error.
  func resolve(
    source: InputType?
  ) async -> Result<OutputType?, ErrorType>
}

public actor ClientMetaDataResolver: ClientMetaDataResolverType {

  private let fetcher: Fetcher<ClientMetaData>

  /**
    Initializes an instance.
   */
  public init(
    fetcher: Fetcher<ClientMetaData> = Fetcher()
  ) {
    self.fetcher = fetcher
  }

  /// Resolves client metadata asynchronously.
  ///
  /// - Parameters:
  ///   - source: The input source for resolving metadata.
  /// - Returns: An asynchronous result containing the resolved metadata or an error of type ResolvingError.
  public func resolve(
    source: ClientMetaDataSource?
  ) async -> Result<ClientMetaData?, ResolvingError> {
    guard let source = source else { return .success(nil) }
    switch source {
    case .passByValue(let metaData):
      return .success(metaData)
    }
  }
}

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

public class ClientMetaDataResolver: ClientMetaDataResolverType {
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

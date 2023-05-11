import Foundation

public protocol ClientMetaDataResolverType {
  associatedtype InputType
  associatedtype OutputType: Codable, Equatable
  associatedtype ErrorType: Error
  func resolve(
    fetcher: Fetcher<OutputType>,
    source: InputType
  ) async -> Result<OutputType, ErrorType>
}

public class ClientMetaDataResolver: ClientMetaDataResolverType {
  public func resolve(
    fetcher: Fetcher<ClientMetaData> = Fetcher(),
    source: ClientMetaDataSource
  ) async -> Result<ClientMetaData, ResolvingError> {
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

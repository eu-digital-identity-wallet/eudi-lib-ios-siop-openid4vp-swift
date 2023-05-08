import Foundation

public protocol ClientMetaDataResolving {
  associatedtype InputType
  associatedtype OutputType: Codable
  associatedtype ErrorType: Error
  func resolve(
    fetcher: Fetcher<OutputType>,
    source: InputType
  ) async -> Result<OutputType, ErrorType>
}

public class ClientMetaDataResolver: ClientMetaDataResolving {
  public func resolve(
    fetcher: Fetcher<ClientMetaData>,
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

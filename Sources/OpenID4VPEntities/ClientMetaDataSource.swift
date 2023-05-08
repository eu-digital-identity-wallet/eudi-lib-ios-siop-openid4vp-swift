import Foundation

public enum ClientMetaDataSource {
  case passByValue(metaData: ClientMetaData)
  case fetchByReference(url: URL)
}

extension ClientMetaDataSource {
  init?(authorizationRequestData: AuthorizationRequestUnprocessedData) {
    if let metaData = authorizationRequestData.clientMetaData,
       let clientMetaData = try? ClientMetaData(metaData: metaData) {
      self = .passByValue(metaData: clientMetaData)
    } else if let clientMetadataUri = authorizationRequestData.clientMetadataUri,
              let uri = URL(string: clientMetadataUri),
              uri.scheme == "https" {
      self = .fetchByReference(url: uri)
    } else {
      return nil
    }
  }
}

import Foundation

public enum ClientMetaDataSource {
  case passByValue(metaData: ClientMetaData)
  case fetchByReference(url: URL)
}

extension ClientMetaDataSource {
  init?(authorizationRequestData: AuthorizationRequestData) {
    if let clientMetaData = authorizationRequestData.clientMetaData {
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

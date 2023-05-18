import Foundation
import PresentationExchange

public enum ClientMetaDataSource {
  case passByValue(metaData: ClientMetaData)
  case fetchByReference(url: URL)
}

extension ClientMetaDataSource {
  init?(authorizationRequestData: AuthorizationRequestUnprocessedData) {
    if let metaData = authorizationRequestData.clientMetaData,
       let clientMetaData = try? ClientMetaData(metaDataString: metaData) {
      self = .passByValue(metaData: clientMetaData)
    } else if let clientMetadataUri = authorizationRequestData.clientMetadataUri,
              let uri = URL(string: clientMetadataUri) {
      self = .fetchByReference(url: uri)
    } else {
      return nil
    }
  }

  init?(authorizationRequestObject: JSONObject) {
    if let metaData = authorizationRequestObject["client_metadata"] as? JSONObject,
       let clientMetaData = try? ClientMetaData(metaData: metaData) {
      self = .passByValue(metaData: clientMetaData)
    } else if let clientMetadataUri = authorizationRequestObject["client_metadata_uri"] as? String,
              let uri = URL(string: clientMetadataUri) {
      self = .fetchByReference(url: uri)
    } else {
      return nil
    }
  }
}

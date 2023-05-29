import Foundation
import PresentationExchange

/// An enumeration representing different data sources for client metadata.
public enum ClientMetaDataSource {
  case passByValue(metaData: ClientMetaData)
  case fetchByReference(url: URL)
}

/// Extension providing additional functionality to the `ClientMetaDataSource` enumeration.
extension ClientMetaDataSource {
  /// Initializes a `ClientMetaDataSource` based on the authorization request data.
  /// - Parameter authorizationRequestData: The authorization request data.
  /// - Returns: A `ClientMetaDataSource` instance if the data can be used as a data source, or `nil` if not.
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

  /// Initializes a `ClientMetaDataSource` based on the authorization request object.
  /// - Parameter authorizationRequestObject: The authorization request object.
  /// - Returns: A `ClientMetaDataSource` instance if the object can be used as a data source, or `nil` if not.
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

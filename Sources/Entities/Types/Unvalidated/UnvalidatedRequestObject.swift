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
@preconcurrency import SwiftyJSON

/*
 *
 * https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-authorization-request
 */
public struct UnvalidatedRequestObject: Codable, Sendable {
  public let responseType: String?
  public let responseUri: String?
  public let redirectUri: String?
  public let dcqlQuery: JSON?
  public let request: String?
  public let requestUri: String?
  public let requestUriMethod: String?
  public let clientMetaData: String?
  public let clientId: String?
  public let clientMetadataUri: String?
  public let clientIdScheme: String?
  public let nonce: String?
  public let scope: String?
  public let responseMode: String?
  public let state: String? // OpenId4VP specific, not utilized from ISO-23330-4
  public let supportedAlgorithm: String?
  public let transactionData: [String]?
  public let verifierInfo: [JSON]?

  enum CodingKeys: String, CodingKey {
    case responseType = "response_type"
    case responseUri = "response_uri"
    case redirectUri = "redirect_uri"
    case dcqlQuery = "dcql_query"
    case clientId = "client_id"
    case clientMetaData = "client_metadata"
    case clientMetadataUri = "client_metadata_uri"
    case clientIdScheme = "client_id_scheme"
    case nonce
    case scope
    case responseMode = "response_mode"
    case state = "state"
    case request
    case requestUri = "request_uri"
    case requestUriMethod = "request_uri_method"
    case supportedAlgorithm = "supported_algorithm"
    case transactionData = "transaction_data"
    case verifierInfo = "verifier_info"
  }

  public init(
    responseType: String? = nil,
    responseUri: String? = nil,
    redirectUri: String? = nil,
    dcqlQuery: JSON? = nil,
    request: String? = nil,
    requestUri: String? = nil,
    requestUriMethod: String? = nil,
    clientMetaData: String? = nil,
    clientId: String? = nil,
    clientMetadataUri: String? = nil,
    clientIdScheme: String? = nil,
    nonce: String? = nil,
    scope: String? = nil,
    responseMode: String? = nil,
    state: String? = nil,
    supportedAlgorithm: String? = nil,
    transactionData: [String]? = nil,
    verifierInfo: [JSON]? = nil
  ) {
    self.responseType = responseType
    self.responseUri = responseUri
    self.redirectUri = redirectUri
    self.dcqlQuery = dcqlQuery
    self.request = request
    self.requestUri = requestUri
    self.requestUriMethod = requestUriMethod
    self.clientMetaData = clientMetaData
    self.clientId = clientId
    self.clientMetadataUri = clientMetadataUri
    self.clientIdScheme = clientIdScheme
    self.nonce = nonce
    self.scope = scope
    self.responseMode = responseMode
    self.state = state
    self.supportedAlgorithm = supportedAlgorithm
    self.transactionData = transactionData
    self.verifierInfo = verifierInfo
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    responseType = try? container.decode(String.self, forKey: .responseType)
    responseUri = try? container.decode(String.self, forKey: .responseUri)
    redirectUri = try? container.decode(String.self, forKey: .redirectUri)

    dcqlQuery = try? container.decode(JSON.self, forKey: .dcqlQuery)

    clientId = try? container.decode(String.self, forKey: .clientId)
    clientMetaData = try? container.decode(String.self, forKey: .clientMetaData)
    clientMetadataUri = try? container.decode(String.self, forKey: .clientMetadataUri)

    clientIdScheme = try? container.decode(String.self, forKey: .clientIdScheme)
    nonce = try? container.decode(String.self, forKey: .nonce)
    scope = try? container.decode(String.self, forKey: .scope)
    responseMode = try? container.decode(String.self, forKey: .responseMode)
    state = try? container.decode(String.self, forKey: .state)

    request = try? container.decode(String.self, forKey: .request)
    requestUri = try? container.decode(String.self, forKey: .requestUri)
    requestUriMethod = try? container.decode(String.self, forKey: .requestUriMethod)

    supportedAlgorithm = try? container.decode(String.self, forKey: .supportedAlgorithm)

    transactionData = try? container.decode([String].self, forKey: .transactionData)
    verifierInfo = try? container.decode([JSON].self, forKey: .verifierInfo)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try? container.encode(responseType, forKey: .responseType)
    try? container.encode(responseUri, forKey: .responseUri)
    try? container.encode(redirectUri, forKey: .redirectUri)

    try? container.encode(dcqlQuery, forKey: .dcqlQuery)

    try? container.encode(clientId, forKey: .clientId)
    try? container.encode(clientMetaData, forKey: .clientMetaData)
    try? container.encode(clientMetadataUri, forKey: .clientMetadataUri)
    try? container.encode(clientIdScheme, forKey: .clientIdScheme)

    try? container.encode(nonce, forKey: .nonce)
    try? container.encode(scope, forKey: .scope)
    try? container.encode(responseMode, forKey: .responseMode)
    try? container.encode(state, forKey: .state)

    try? container.encode(request, forKey: .request)
    try? container.encode(requestUri, forKey: .requestUri)
    try? container.encode(requestUriMethod, forKey: .requestUriMethod)

    try? container.encode(supportedAlgorithm, forKey: .supportedAlgorithm)
    try? container.encode(transactionData, forKey: .transactionData)
    try? container.encode(verifierInfo, forKey: .verifierInfo)
  }
}

public extension UnvalidatedRequestObject {
  init?(from url: URL) {
    let parameters = url.queryParameters

    responseType = parameters?[CodingKeys.responseType.rawValue] as? String
    responseUri = parameters?[CodingKeys.responseUri.rawValue] as? String
    redirectUri = parameters?[CodingKeys.redirectUri.rawValue] as? String

    if let dcqlString = parameters?[CodingKeys.dcqlQuery.rawValue] as? String,
       let jsonData = dcqlString.data(using: .utf8) {
      dcqlQuery = try? JSON(data: jsonData)
    } else {
      dcqlQuery = nil
    }

    clientId = parameters?[CodingKeys.clientId.rawValue] as? String
    clientMetaData = parameters?[CodingKeys.clientMetaData.rawValue] as? String
    clientMetadataUri = parameters?[CodingKeys.clientMetadataUri.rawValue] as? String

    clientIdScheme = parameters?[CodingKeys.clientIdScheme.rawValue] as? String
    nonce = parameters?[CodingKeys.nonce.rawValue] as? String
    scope = parameters?[CodingKeys.scope.rawValue] as? String
    responseMode = parameters?[CodingKeys.responseMode.rawValue] as? String
    state = parameters?[CodingKeys.state.rawValue] as? String

    request = parameters?[CodingKeys.request.rawValue] as? String
    requestUri = parameters?[CodingKeys.requestUri.rawValue] as? String
    requestUriMethod = parameters?[CodingKeys.requestUriMethod.rawValue] as? String

    supportedAlgorithm = parameters?[CodingKeys.supportedAlgorithm.rawValue] as? String
    transactionData = JsonHelper.jsonArray(
      for: "transaction_data",
      from: url
    )?.compactMap { $0.string }

    verifierInfo = JsonHelper.jsonArray(
      for: "verifier_info",
      from: url
    )
  }
}

public extension UnvalidatedRequestObject {
  var hasClientMetaData: Bool {
    return clientMetaData != nil || clientMetadataUri != nil
  }

  var hasRequests: Bool {
    return request != nil || requestUri != nil
  }

  var hasConflicts: Bool {
    return hasClientMetaData && hasRequests
  }
}

/// A utility to help with JSON parsing from query parameters.
internal struct JsonHelper {
  /// Parses a JSON array from the query parameter in the provided URL.
  /// - Parameters:
  ///   - parameter: The query parameter key.
  ///   - url: The URL containing the query parameter.
  /// - Returns: An optional array of JSON elements, or `nil` if parsing fails.
  static func jsonArray(for parameter: String, from url: URL) -> [JSON]? {
    guard
      let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
      let paramValue = queryItems.first(where: { $0.name == parameter })?.value,
      let data = paramValue.data(using: .utf8)
    else {
      return nil
    }

    let json = try? JSON(data: data)
    return json?.array
  }
}

public extension UnvalidatedRequestObject {
  
  func validate(
    against dcql: DCQL,
    walletSupportsVpFormats: Set<String>
  ) throws {
    
    let _: Set<QueryId> = Set(dcql.credentials.map { $0.id })

    let queryFormats: Set<String> = Set(dcql.credentials.map { $0.format.format })
    let unsupported = queryFormats.subtracting(walletSupportsVpFormats)
    guard unsupported.isEmpty else {
      throw DCQLError.error("Unsupported query format(s): \(Array(unsupported))")
    }
  }
}

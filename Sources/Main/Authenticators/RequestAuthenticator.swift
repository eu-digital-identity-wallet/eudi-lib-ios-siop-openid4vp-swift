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
import SwiftyJSON

internal struct AuthenticatedRequest: Sendable {
  let client: Client
  let requestObject: UnvalidatedRequestObject
}

internal struct JWTDecoder {

  static func decodeJWT(_ jwt: String) -> UnvalidatedRequestObject? {
    let segments = jwt.components(separatedBy: ".")
    guard segments.count >= 2 else { return nil }

    let payloadSegment = segments[1]

    // Pad base64 string if needed
    let requiredLength = 4 * ((payloadSegment.count + 3) / 4)
    let paddingLength = requiredLength - payloadSegment.count
    let base64 = payloadSegment + String(repeating: "=", count: paddingLength)

    guard let payloadData = Data(base64Encoded: base64) else { return nil }

    do {
      let json = try JSON(data: payloadData)
      return mapJSONToRequestObject(json)
    } catch {
      return nil
    }
  }

  private static func mapJSONToRequestObject(_ json: JSON) -> UnvalidatedRequestObject {
    var dcqlQuery: JSON?
    let raw = JSON(json["dcql_query"])
    if raw != .null {
      dcqlQuery = raw
    }

    let pd = json["presentation_definition"].dictionaryObject?.toJSONString() ?? json["presentation_definition"].string
    let transactionData = json["transaction_data"].arrayObject as? [String]
    let verifierInfo = json["verifier_info"].arrayValue

    return UnvalidatedRequestObject(
      responseType: json["response_type"].string,
      responseUri: json["response_uri"].string,
      redirectUri: json["redirect_uri"].string,
      presentationDefinition: pd,
      presentationDefinitionUri: json["presentation_definition_uri"].string,
      dcqlQuery: dcqlQuery,
      request: json["request"].string,
      requestUri: json["request_uri"].string,
      requestUriMethod: json["request_uri_method"].string,
      clientMetaData: json["client_metadata"].dictionaryObject?.toJSONString(),
      clientId: json["client_id"].string,
      clientMetadataUri: json["client_metadata_uri"].string,
      clientIdScheme: json["client_id_scheme"].string,
      nonce: json["nonce"].string,
      scope: json["scope"].string,
      responseMode: json["response_mode"].string,
      state: json["state"].string,
      idTokenType: json["id_token_type"].string,
      supportedAlgorithm: json["supported_algorithm"].string,
      transactionData: transactionData,
      verifierInfo: verifierInfo
    )
  }
}

internal actor RequestAuthenticator {

  let config: SiopOpenId4VPConfiguration
  let clientAuthenticator: ClientAuthenticator

  init(config: SiopOpenId4VPConfiguration, clientAuthenticator: ClientAuthenticator) {
    self.config = config
    self.clientAuthenticator = clientAuthenticator
  }

  func authenticate(fetchRequest: FetchedRequest) async throws -> AuthenticatedRequest {
    let client = try await clientAuthenticator.authenticate(
      fetchRequest: fetchRequest
    )
    switch fetchRequest {
    case .plain(let requestObject):
      return .init(client: client, requestObject: requestObject)
    case .jwtSecured(let clientId, let jwt):
      guard let requestObject = JWTDecoder.decodeJWT(jwt) else {
        throw ValidationError.invalidRequest
      }

      try await verify(
        validator: AccessValidator(
          walletOpenId4VPConfig: config
        ),
        token: jwt,
        clientId: clientId
      )

      return .init(client: client, requestObject: requestObject)
    }
  }

  func verify(
    validator: AccessValidating,
    token: JWTString,
    clientId: String?
  ) async throws {
    try? await validator.validate(clientId: clientId, jwt: token)
  }

  func createIdVpToken(
    clientId: String,
    client: Client,
    nonce: String,
    requestObject: UnvalidatedRequestObject,
    clientMetaData: ClientMetaData.Validated
  ) throws -> ValidatedRequestData {
    let formats: VpFormats = clientMetaData.vpFormats
    let querySource = try parseQuerySource(
      requestObject: requestObject
    )

    return .idAndVpToken(request: .init(
      idTokenType: try .init(authorizationRequestData: requestObject),
      querySource: querySource,
      clientMetaDataSource: nil,
      clientId: clientId,
      client: client,
      nonce: nonce,
      scope: requestObject.scope,
      responseMode: requestObject.validResponseMode,
      state: requestObject.state,
      vpFormats: formats.values.isEmpty ? try VpFormats.default() : formats,
      transactionData: requestObject.transactionData,
      verifierInfo:  try requestObject.verifierInfo?.map({ json in
        try VerifierInfo.from(json: json)
      })
    ))
  }

  func createIdToken(
    clientId: String,
    client: Client,
    nonce: String,
    requestObject: UnvalidatedRequestObject
  ) throws -> ValidatedRequestData {
    
    let querySource = try parseQuerySource(
      requestObject: requestObject
    )
    
    return .idToken(request: .init(
      querySource: querySource,
      idTokenType: try .init(authorizationRequestData: requestObject),
      clientMetaDataSource: nil,
      clientId: clientId,
      client: client,
      nonce: nonce,
      scope: requestObject.scope,
      responseMode: try? .init(authorizationRequestData: requestObject),
      state: requestObject.state,
      transactionData: requestObject.transactionData,
      verifierInfo:  try requestObject.verifierInfo?.map({ json in
        try VerifierInfo.from(json: json)
      })
    ))
  }

  // Create a VP token request
  func createVpToken(
    clientId: String,
    client: Client,
    nonce: String,
    requestObject: UnvalidatedRequestObject,
    clientMetaData: ClientMetaData.Validated
  ) throws -> ValidatedRequestData {
    let formats: VpFormats = clientMetaData.vpFormats
    let querySource = try parseQuerySource(
      requestObject: requestObject
    )

    return .vpToken(request: .init(
      querySource: querySource,
      clientMetaDataSource: nil,
      clientId: clientId,
      client: client,
      nonce: nonce,
      responseMode: requestObject.validResponseMode,
      requestUriMethod: .init(method: requestObject.requestUriMethod),
      state: requestObject.state,
      vpFormats: formats.values.isEmpty ? try VpFormats.default() : formats,
      transactionData: requestObject.transactionData,
      verifierInfo:  try requestObject.verifierInfo?.map({ json in
        try VerifierInfo.from(json: json)
      })
    ))
  }

  func parseQuerySource(requestObject: UnvalidatedRequestObject) throws -> QuerySource {

    let hasPd = requestObject.presentationDefinition != nil
    let hasPdUri = requestObject.presentationDefinitionUri != nil
    let hasDcqlQuery = requestObject.dcqlQuery?.exists() ?? false

    let querySourceCount = [hasPd, hasPdUri, hasDcqlQuery].filter { $0 }.count

    if querySourceCount > 1 {
      throw ValidationError.multipleQuerySources
    }

    if hasPd || hasPdUri {
      return .byPresentationDefinitionSource(
        try .init(authorizationRequestData: requestObject)
      )
    } else if hasDcqlQuery, let dcqlQuery = requestObject.dcqlQuery {
      return .dcqlQuery(
        try .init(
          from: dcqlQuery
        )
      )

    } else {
      throw ValidationError.invalidQuerySource
    }
  }
}

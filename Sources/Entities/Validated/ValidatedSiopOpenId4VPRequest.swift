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
import PresentationExchange
import JOSESwift
import X509
import SwiftyJSON

// Enum defining the types of validated SIOP OpenID4VP requests
public enum ValidatedSiopOpenId4VPRequest {
  case idToken(request: IdTokenRequest)
  case vpToken(request: VpTokenRequest)
  case idAndVpToken(request: IdAndVpTokenRequest)
  
  public var transactionData: [String]? {
    switch self {
    case .idToken:
      return nil
    case .vpToken(let request):
      return request.transactionData
    case .idAndVpToken(let request):
      return request.transactionData
    }
  }
  
  public var responseMode: ResponseMode? {
    switch self {
    case .idToken(let request):
      request.responseMode
    case .vpToken(let request):
      request.responseMode
    case .idAndVpToken(let request):
      request.responseMode
    }
  }
  
  public var nonce: String? {
    switch self {
    case .idToken(let request):
      request.nonce
    case .vpToken(let request):
      request.nonce
    case .idAndVpToken(let request):
      request.nonce
    }
  }
  
  public var state: String? {
    switch self {
    case .idToken(let request):
      request.state
    case .vpToken(let request):
      request.state
    case .idAndVpToken(let request):
      request.state
    }
  }
  
  public var clientId: VerifierId {
    switch self {
    case .idToken(let request):
      request.client.id
    case .vpToken(let request):
      request.client.id
    case .idAndVpToken(let request):
      request.client.id
    }
  }
  
  public func clientMetaData() async -> ClientMetaData.Validated? {
    let source = switch self {
    case .idToken(let request):
      request.clientMetaDataSource
    case .vpToken(let request):
      request.clientMetaDataSource
    case .idAndVpToken(let request):
      request.clientMetaDataSource
    }
    
    switch source {
    case .passByValue(let metadata):
      return try? await ClientMetaDataValidator().validate(
        clientMetaData: metadata
      )
    case .none:
      return nil
    }
  }
}

// Extension for ValidatedSiopOpenId4VPRequest
public extension ValidatedSiopOpenId4VPRequest {
  
  static let WALLET_NONCE_FORM_PARAM = "wallet_nonce"
  static let WALLET_METADATA_FORM_PARAM = "wallet_metadata"
  
  // Initialize with a request URI
  init(
    requestUri: JWTURI,
    requestUriMethod: RequestUriMethod = .GET,
    clientId: String?,
    walletConfiguration: SiopOpenId4VPConfiguration? = nil
  ) async throws {
    
    guard let requestUrl = URL(string: requestUri) else {
      throw ValidationError.invalidRequestUri(requestUri)
    }
    
    let jwt = try await Self.getJWT(
      requestUriMethod: requestUriMethod,
      config: walletConfiguration,
      requestUrl: requestUrl,
      clientId: clientId
    )
    
    // Extract the payload from the JSON Web Token
    guard let payload = JSONWebToken(jsonWebToken: jwt)?.payload else {
      throw ValidationError.invalidAuthorizationData
    }
    
    // Extract the client ID and nonce from the payload
    guard let payloadcClientId = payload[Constants.CLIENT_ID].string else {
      throw ValidationError.missingRequiredField(".clientId")
    }
    
    guard let nonce = payload[Constants.NONCE].string else {
      throw ValidationError.missingRequiredField(".nonce")
    }
    
    let responseType = try ResponseType(authorizationRequestObject: payload)
    
    try await Self.verify(
      token: jwt,
      clientId: clientId,
      walletConfiguration: walletConfiguration
    )
    
    let client = try await Self.getClient(
      clientId: clientId,
      jwt: jwt,
      config: walletConfiguration
    )
    
    // Initialize the validated request based on the response type
    switch responseType {
    case .idToken:
      self = try ValidatedSiopOpenId4VPRequest.createIdToken(
        clientId: payloadcClientId,
        client: client,
        nonce: nonce,
        authorizationRequestObject: payload
      )
    case .vpToken:
      self = try ValidatedSiopOpenId4VPRequest.createVpToken(
        clientId: payloadcClientId,
        client: client,
        nonce: nonce,
        authorizationRequestObject: payload
      )
    case .vpAndIdToken:
      self = try ValidatedSiopOpenId4VPRequest.createIdVpToken(
        clientId: client.id.originalClientId,
        client: client,
        nonce: nonce,
        authorizationRequestObject: payload
      )
    case .code:
      throw ValidationError.unsupportedResponseType(".code")
    }
  }
  
  // Initialize with a JWT string
  init(
    request: JWTString,
    requestUriMethod: RequestUriMethod = .GET,
    walletConfiguration: SiopOpenId4VPConfiguration? = nil
  ) async throws {
    
    // Create a JSONWebToken from the JWT string
    let jsonWebToken = JSONWebToken(jsonWebToken: request)
    
    // Extract the payload from the JSON Web Token
    guard let payload = jsonWebToken?.payload else {
      throw ValidationError.invalidAuthorizationData
    }
    
    // Extract the client ID and nonce from the payload
    guard let clientId = payload[Constants.CLIENT_ID].string else {
      throw ValidationError.missingRequiredField(".clientId")
    }
    
    guard let nonce = payload[Constants.NONCE].string else {
      throw ValidationError.missingRequiredField(".nonce")
    }
    
    // Determine the response type from the payload
    let responseType = try ResponseType(authorizationRequestObject: payload)
    
    try await ValidatedSiopOpenId4VPRequest.verify(
      token: request,
      clientId: clientId,
      walletConfiguration: walletConfiguration
    )
    
    let client = try await Self.getClient(
      clientId: clientId,
      jwt: request,
      config: walletConfiguration
    )
    
    // Initialize the validated request based on the response type
    switch responseType {
    case .idToken:
      self = try ValidatedSiopOpenId4VPRequest.createIdToken(
        clientId: clientId,
        client: client,
        nonce: nonce,
        authorizationRequestObject: payload
      )
    case .vpToken:
      self = try ValidatedSiopOpenId4VPRequest.createVpToken(
        clientId: clientId,
        client: client,
        nonce: nonce,
        authorizationRequestObject: payload
      )
    case .vpAndIdToken:
      self = try ValidatedSiopOpenId4VPRequest.createIdVpToken(
        clientId: clientId,
        client: client,
        nonce: nonce,
        authorizationRequestObject: payload
      )
    case .code:
      throw ValidationError.unsupportedResponseType(".code")
    }
  }
  
  // Initialize with an AuthorisationRequestObject object
  init(
    authorizationRequestData: AuthorisationRequestObject,
    walletConfiguration: SiopOpenId4VPConfiguration? = nil
  ) async throws {
    let requesrUriMethod: RequestUriMethod = .init(
      method: authorizationRequestData.requestUriMethod
    )
    
    if let request = authorizationRequestData.request {
      try await self.init(
        request: request,
        requestUriMethod: requesrUriMethod,
        walletConfiguration: walletConfiguration
      )
      
    } else if let requestUrl = authorizationRequestData.requestUri {
      try await self.init(
        requestUri: requestUrl,
        requestUriMethod: requesrUriMethod,
        clientId: authorizationRequestData.clientId,
        walletConfiguration: walletConfiguration
      )
      
    } else {
      // Determine the response type from the authorization request data
      let responseType = try ResponseType(authorizationRequestData: authorizationRequestData)
      
      // Extract the nonce from the authorization request data
      guard let nonce = authorizationRequestData.nonce else {
        throw ValidationError.missingRequiredField(".nonce")
      }
      
      // Extract the client ID from the authorization request data
      guard let payloadcClientId = authorizationRequestData.clientId else {
        throw ValidationError.missingRequiredField(".clientId")
      }
      
      let client = try await Self.getClient(
        clientId: payloadcClientId,
        config: walletConfiguration
      )
      
      let jsonData = try JSONEncoder().encode(authorizationRequestData)
      let payload = try JSON(data: jsonData)
      
      // Initialize the validated request based on the response type
      switch responseType {
      case .idToken:
        self = try Self.createIdToken(
          clientId: payloadcClientId,
          client: client,
          nonce: nonce,
          authorizationRequestObject: payload
        )
      case .vpToken:
        self = try Self.createVpToken(
          clientId: payloadcClientId,
          client: client,
          nonce: nonce,
          authorizationRequestObject: payload
        )
      case .vpAndIdToken:
        self = try Self.createIdVpToken(
          clientId: payloadcClientId,
          client: client,
          nonce: nonce,
          authorizationRequestObject: payload
        )
      case .code:
        throw ValidationError.unsupportedResponseType(".code")
      }
    }
  }
  
  fileprivate static func getJWT(
    requestUriMethod: RequestUriMethod = .GET,
    config: SiopOpenId4VPConfiguration?,
    requestUrl: URL,
    clientId: String?
  ) async throws -> String {
    switch requestUriMethod {
    case .GET:
      try await Self.getJwtViaGET(
        config: config,
        requestUrl: requestUrl
      )
    case .POST:
      try await getJwtViaPOST(
        config: config,
        requestUrl: requestUrl,
        clientId: clientId
      )
    }
  }
  
  private static func getJwtViaGET(
    config: SiopOpenId4VPConfiguration?,
    requestUrl: URL
  ) async throws -> String {
    return try await Self.getJwtString(
      fetcher: Fetcher(
        session: config?.session ?? URLSession.shared
      ),
      requestUrl: requestUrl)
  }
  
  private static func getJwtViaPOST(
    config: SiopOpenId4VPConfiguration?,
    requestUrl: URL,
    clientId: String?
  ) async throws -> String {
    guard let supportedMethods = config?.jarConfiguration.supportedRequestUriMethods else {
      throw AuthorizationError.invalidRequestUriMethod
    }

    guard let options = supportedMethods.isPostSupported() else {
      throw AuthorizationError.invalidRequestUriMethod
    }

    let isNotRequired = options.jarEncryption.isNotRequired
    let nonce = generateNonce(from: options)
    let keys: (key: SecKey, jwk: ECPrivateKey)? = !isNotRequired ? (try? generateKeysIfNeeded(
      for: supportedMethods
    )) : nil
    
    let walletMetadata = generateWalletMetadataIfNeeded(
      config: config,
      key: keys?.key,
      include: options.includeWalletMetadata
    )

    let jwt = try await Self.postJwtString(
      walletMetaData: walletMetadata,
      nonce: nonce,
      requestUrl: requestUrl
    )

    let finalJwt = try decryptIfNeeded(
      jwt: jwt,
      keyManagementAlgorithm: config?.jarConfiguration.supportedEncryption?.supportedEncryptionAlgorithm,
      contentEncryptionAlgorithm: config?.jarConfiguration.supportedEncryption?.supportedEncryptionMethod,
      keys: keys
    )
    
    try config?.ensureValid(
      expectedClient: clientId,
      expectedWalletNonce: nonce,
      jwt: finalJwt
    )

    return finalJwt
  }
  
  private static func generateNonce(from options: PostOptions) -> String? {
    return switch options.useWalletNonce {
    case .doNotUse: nil
    case .use(let byteLength): NonceGenerator.generate(length: byteLength)
    }
  }
  
  private static func generateKeysIfNeeded(
    for method: SupportedRequestUriMethod
  ) throws -> (key: SecKey, jwk: ECPrivateKey)? {
    switch method {
    case .post, .both: break
    default:
      return nil
    }
    let key = try KeyController.generateECDHPrivateKey()
    let jwk = try ECPrivateKey(privateKey: key)
    return (key, jwk)
  }
  
  private static func generateWalletMetadataIfNeeded(
    config: SiopOpenId4VPConfiguration?,
    key: SecKey?,
    include: Bool
  ) -> JSON? {
    guard include, let config else { return nil }
    return walletMetaData(cfg: config, key: key)
  }
  
  private static func decryptIfNeeded(
    jwt: String,
    keyManagementAlgorithm: KeyManagementAlgorithm?,
    contentEncryptionAlgorithm: ContentEncryptionAlgorithm?,
    keys: (key: SecKey, jwk: ECPrivateKey)?
  ) throws -> String {
    guard let jwk = keys?.jwk else {
      return jwt
    }

    guard let keyManagementAlgorithm, let contentEncryptionAlgorithm else {
      throw AuthorizationError.invalidAlgorithms
    }
    
    let encryptedJwe = try JWE(compactSerialization: jwt)
    guard let decrypter = Decrypter(
      keyManagementAlgorithm: keyManagementAlgorithm,
      contentEncryptionAlgorithm: contentEncryptionAlgorithm,
      decryptionKey: jwk
    ) else {
      throw AuthorizationError.jwtDecryptionFailed
    }

    let payloadData = try encryptedJwe.decrypt(using: decrypter).data()
    guard let decoded = payloadData.base64EncodedString().base64Decoded(),
          let jwtString = String(data: decoded, encoding: .utf8) else {
      throw AuthorizationError.jwtDecryptionFailed
    }

    return jwtString
  }
  
  fileprivate struct ResultType: Codable {}
  fileprivate static func getJwtString(
    fetcher: Fetcher<ResultType> = Fetcher(),
    requestUrl: URL
  ) async throws -> String {
    let jwtResult = try await fetcher.fetchString(url: requestUrl)
    switch jwtResult {
    case .success(let string):
      return try Self.extractJWT(string)
    case .failure: throw ValidationError.invalidJwtPayload
    }
  }
  
  fileprivate static func postJwtString(
    poster: Poster = Poster(),
    walletMetaData: JSON?,
    nonce: String?,
    requestUrl: URL
  ) async throws -> String {
    
    // Building a combined JSON object
    var combined: [String: Any] = [:]
    if let walletMetaData = walletMetaData {
      combined[Self.WALLET_METADATA_FORM_PARAM] = walletMetaData.dictionaryObject?.toJSONString()
    }
    
    // Convert nonce to JSON and add to combined JSON
    if let nonce = nonce {
      combined[Self.WALLET_NONCE_FORM_PARAM] = nonce
    }
    
    let post = VerifierFormPost(
      additionalHeaders: ["Content-Type": ContentType.form.rawValue],
      url: requestUrl,
      formData: combined
    )
    
    let jwtResult: Result<String, PostError> = await poster.postString(
      request: post.urlRequest
    )
    switch jwtResult {
    case .success(let string):
      return try Self.extractJWT(string)
    case .failure: throw ValidationError.invalidJwtPayload
    }
  }
}

public extension ValidatedSiopOpenId4VPRequest {
  static func getClient(
    clientId: String?,
    jwt: JWTString,
    config: SiopOpenId4VPConfiguration?
  ) async throws -> Client {
    
    guard let clientId else {
      throw ValidationError.validationError("clientId is missing")
    }
    
    guard !clientId.isEmpty else {
      throw ValidationError.validationError("clientId is missing")
    }
    
    guard
      let verifierId = try? VerifierId.parse(clientId: clientId).get(),
      let scheme = config?.supportedClientIdSchemes.first(
        where: { $0.scheme.rawValue == verifierId.scheme.rawValue }
      ) ?? config?.supportedClientIdSchemes.first
    else {
      throw ValidationError.validationError("No supported client Id scheme")
    }
    
    switch scheme {
    case .preregistered(let clients):
      guard let client = clients[verifierId.originalClientId] else {
        throw ValidationError.validationError("preregistered client not found")
      }
      return .preRegistered(
        clientId: clientId,
        legalName: client.legalName
      )
      
    case .x509SanUri,
        .x509SanDns:
      guard let jws = try? JWS(compactSerialization: jwt) else {
        throw ValidationError.validationError("Unable to process JWT")
      }
      
      guard let chain: [String] = jws.header.x5c else {
        throw ValidationError.validationError("No certificate in header")
      }
      
      let certificates: [Certificate] = parseCertificates(from: chain)
      guard let certificate = certificates.first else {
        throw ValidationError.validationError("No certificate in chain")
      }
      
      return .x509SanUri(
        clientId: clientId,
        certificate: certificate
      )
      
    case .did(let keyLookup):
      return try await Self.didPublicKeyLookup(
        jws: try JWS(compactSerialization: jwt),
        clientId: clientId,
        keyLookup: keyLookup
      )
      
    case .verifierAttestation:
      return try Self.verifierAttestation(
        jwt: jwt,
        supportedScheme: scheme,
        clientId: clientId
      )
    case .redirectUri:
      guard let url = URL(string: verifierId.originalClientId) else {
        throw ValidationError.validationError("Client id must be uri for redirectUri scheme")
      }
      
      let configUrl = config?
        .supportedClientIdSchemes
        .first(where: { $0.scheme == scheme.scheme })?
        .redirectUri
      
      guard url == configUrl else {
        throw ValidationError.validationError("Client id must be uri for redirectUri scheme")
      }
      
      return .redirectUri(
        clientId: url
      )
    }
  }
  
  static func getClient(
    clientId: String,
    config: SiopOpenId4VPConfiguration?
  ) async throws -> Client {
    guard
      let verifierId = try? VerifierId.parse(clientId: clientId).get(),
      let scheme = config?.supportedClientIdSchemes.first(
        where: { $0.scheme.rawValue == verifierId.scheme.rawValue }
      ) ?? config?.supportedClientIdSchemes.first
    else {
      throw ValidationError.validationError("No supported client Id scheme")
    }
    
    switch scheme {
    case .preregistered(let clients):
      guard let client = clients[clientId] else {
        throw ValidationError.validationError("preregistered client nort found")
      }
      return .preRegistered(
        clientId: clientId,
        legalName: client.legalName
      )
    case .redirectUri:
      guard let url = URL(string: clientId) else {
        throw ValidationError.validationError("Client id must be uri for redirectUri scheme")
      }
      
      let configUrl = config?
        .supportedClientIdSchemes
        .first(where: { $0.scheme == scheme.scheme })?
        .redirectUri
      
      guard url == configUrl else {
        throw ValidationError.validationError("Client id must be uri for redirectUri scheme")
      }
      
      return .redirectUri(
        clientId: url
      )
    default:
      throw ValidationError.validationError("Scheme \(scheme) not supported")
    }
  }
}

// Private extension for ValidatedSiopOpenId4VPRequest
private extension ValidatedSiopOpenId4VPRequest {
  
  private static func verifierAttestation(
    jwt: JWTString,
    supportedScheme: SupportedClientIdScheme,
    clientId: String
  ) throws -> Client {
    guard case let .verifierAttestation(verifier, clockSkew) = supportedScheme else {
      throw ValidationError.validationError("Scheme should be verifier attestation")
    }
    
    guard let jws = try? JWS(compactSerialization: jwt) else {
      throw ValidationError.validationError("Unable to process JWT")
    }
    
    let expectedType = JOSEObjectType(rawValue: "verifier-attestation+jwt")
    guard jws.header.typ == expectedType?.rawValue else {
      throw ValidationError.validationError("verifier-attestation+jwt not found in JWT header")
    }
    
    _ = try jws.validate(using: verifier)
    let claims = try jws.verifierAttestationClaims()
    
    try TimeChecks(skew: clockSkew)
      .verify(
        claimsSet: .init(
          issuer: claims.iss,
          subject: claims.sub,
          audience: [],
          expirationTime: claims.exp,
          notBeforeTime: Date(),
          issueTime: claims.iat,
          jwtID: nil,
          claims: [:]
        )
      )
    return .attested(clientId: clientId)
  }
  
  private static func didPublicKeyLookup(
    jws: JWS,
    clientId: String,
    keyLookup: DIDPublicKeyLookupAgentType
  ) async throws -> Client {
    
    guard let kid = jws.header.kid else {
      throw ValidationError.validationError("kid not found in JWT header")
    }
    
    guard
      let keyUrl = AbsoluteDIDUrl.parse(kid),
      keyUrl.string.hasPrefix(clientId)
    else {
      throw ValidationError.validationError("kid not found in JWT header")
    }
    
    guard let clientIdAsDID = DID.parse(clientId) else {
      throw ValidationError.validationError("Invalid DID")
    }
    
    guard let publicKey = await keyLookup.resolveKey(from: clientIdAsDID) else {
      throw ValidationError.validationError("Unable to extract public key from DID")
    }
    
    try AccessValidator.verifyJWS(
      jws: jws,
      publicKey: publicKey
    )
    
    return .didClient(
      did: clientIdAsDID
    )
  }
  
  static func verify(
    token: JWTString,
    clientId: String?,
    walletConfiguration: SiopOpenId4VPConfiguration? = nil
  ) async throws {
    
    let validator = AccessValidator(walletOpenId4VPConfig: walletConfiguration)
    try? await validator.validate(clientId: clientId, jwt: token)
  }
  
  // Create a VP token request
  static func createVpToken(
    clientId: String,
    nonce: String,
    authorizationRequestData: AuthorisationRequestObject
  ) throws -> ValidatedSiopOpenId4VPRequest {
    let formats = try? VpFormats(
      jsonString: authorizationRequestData.clientMetaData
    )
    return .vpToken(request: .init(
      presentationDefinitionSource: try .init(authorizationRequestData: authorizationRequestData),
      clientMetaDataSource: .init(authorizationRequestData: authorizationRequestData),
      clientId: clientId,
      client: .preRegistered(clientId: clientId, legalName: clientId),
      nonce: nonce,
      responseMode: try? .init(authorizationRequestData: authorizationRequestData),
      requestUriMethod: .init(method: authorizationRequestData.requestUriMethod),
      state: authorizationRequestData.state,
      vpFormats: try (formats ?? VpFormats.empty()),
      transactionData: authorizationRequestData.transactionData
    ))
  }
  
  // Create an ID token request
  static func createIdToken(
    clientId: String,
    client: Client,
    nonce: String,
    authorizationRequestObject: JSON
  ) throws -> ValidatedSiopOpenId4VPRequest {
    .idToken(request: .init(
      idTokenType: try .init(authorizationRequestObject: authorizationRequestObject),
      clientMetaDataSource: .init(authorizationRequestObject: authorizationRequestObject),
      clientId: clientId,
      client: client,
      nonce: nonce,
      scope: authorizationRequestObject[Constants.SCOPE].stringValue,
      responseMode: try? .init(authorizationRequestObject: authorizationRequestObject),
      state: authorizationRequestObject[Constants.STATE].string
    ))
  }
  
  // Create a VP token request
  static func createVpToken(
    clientId: String,
    client: Client,
    nonce: String,
    authorizationRequestObject: JSON
  ) throws -> ValidatedSiopOpenId4VPRequest {
    let formats = try? VpFormats(json: authorizationRequestObject[Constants.CLIENT_METADATA])
    return .vpToken(request: .init(
      presentationDefinitionSource: try .init(authorizationRequestObject: authorizationRequestObject),
      clientMetaDataSource: .init(authorizationRequestObject: authorizationRequestObject),
      clientId: clientId,
      client: client,
      nonce: nonce,
      responseMode: try? .init(authorizationRequestObject: authorizationRequestObject),
      requestUriMethod: .init(method: authorizationRequestObject[Constants.REQUEST_URI_METHOD].string),
      state: authorizationRequestObject[Constants.STATE].string,
      vpFormats: try (formats ?? VpFormats.default()),
      transactionData: authorizationRequestObject[Constants.TRANSACTION_DATA].array?.compactMap { $0.string }
    ))
  }
  
  // Create an ID and VP token request
  static func createIdVpToken(
    clientId: String,
    client: Client,
    nonce: String,
    authorizationRequestObject: JSON
  ) throws -> ValidatedSiopOpenId4VPRequest {
    let formats = try? VpFormats(jsonString: authorizationRequestObject[Constants.CLIENT_METADATA].string)
    return .idAndVpToken(request: .init(
      idTokenType: try .init(authorizationRequestObject: authorizationRequestObject),
      presentationDefinitionSource: try .init(authorizationRequestObject: authorizationRequestObject),
      clientMetaDataSource: .init(authorizationRequestObject: authorizationRequestObject),
      clientId: clientId,
      client: client,
      nonce: nonce,
      scope: authorizationRequestObject[Constants.SCOPE].stringValue,
      responseMode: try? .init(authorizationRequestObject: authorizationRequestObject),
      state: authorizationRequestObject[Constants.STATE].string,
      vpFormats: try (formats ?? VpFormats.default()),
      transactionData: authorizationRequestObject[Constants.TRANSACTION_DATA].array?.compactMap { $0.string }
    ))
  }
  
  /// Extracts the JWT token from a given JSON string or JWT string.
  /// - Parameter string: The input string containing either a JSON object with a JWT field or a JWT string.
  /// - Returns: The extracted JWT token.
  /// - Throws: An error of type `ValidatedAuthorizationError` if the input string is not a valid JSON or JWT, or if there's a decoding error.
  private static func extractJWT(_ string: String) throws -> String {
    if string.isValidJSONString {
      if let jsonData = string.data(using: .utf8) {
        do {
          let decodedObject = try JSONDecoder().decode(RemoteJWT.self, from: jsonData)
          return decodedObject.jwt
        } catch {
          throw error
        }
      } else {
        throw ValidationError.invalidJwtPayload
      }
    } else {
      return string
    }
  }
}

// Protocol to verify JWT claims
private protocol JWTClaimsSetVerifier {
  func verify(claimsSet: JWTClaimsSet) throws
}

private enum JWTVerificationError: Error {
  case expiredJWT
  case issuedInFuture
  case issuedAfterExpiration
  case notYetActive
  case activeAfterExpiration
  case activeBeforeIssuance
}

// Date utility functions similar to DateUtils in Kotlin
private struct DateUtils {
  static func isAfter(_ date1: Date, _ date2: Date, _ skew: TimeInterval) -> Bool {
    return date1.timeIntervalSince(date2) > skew
  }
  
  static func isBefore(_ date1: Date, _ date2: Date, _ skew: TimeInterval = .zero) -> Bool {
    return date1.timeIntervalSince(date2) < -skew
  }
}

// TimeChecks class implementation in Swift
private class TimeChecks: JWTClaimsSetVerifier {
  private let skew: TimeInterval
  
  init(skew: TimeInterval) {
    self.skew = skew
  }
  
  func verify(claimsSet: JWTClaimsSet) throws {
    let now = Date()
    let skewInSeconds = skew
    
    if let exp = claimsSet.expirationTime {
      if !DateUtils.isAfter(exp, now, skewInSeconds) {
        throw JWTVerificationError.expiredJWT
      }
    }
    
    if let iat = claimsSet.issueTime {
      if !DateUtils.isBefore(iat, now) {
        throw JWTVerificationError.issuedInFuture
      }
      
      if let exp = claimsSet.expirationTime, !iat.timeIntervalSince(exp).isLess(than: 0) {
        throw JWTVerificationError.issuedAfterExpiration
      }
    }
  }
}

private extension SiopOpenId4VPConfiguration {
  func ensureValid(
    expectedClient: String?,
    expectedWalletNonce: String?,
    jwt: JWTString
  ) throws {
    
    let jws = try JWS(compactSerialization: jwt)
    
    guard let expectedClient = expectedClient else {
      throw ValidationError.validationError("expectedClient should not be nil")
    }
    
    guard let jwsClientID = getValueForKey(
      from: jwt,
      key: "client_id"
    ) as? String else {
      throw ValidationError.validationError("client_id should not be nil")
    }
    
    let id = try? VerifierId.parse(clientId: jwsClientID).get()
    let expectedId = try? VerifierId.parse(clientId: expectedClient).get()
    guard id?.originalClientId == expectedId?.originalClientId else {
      throw ValidationError.validationError("client_id's do not match")
    }
    
    if expectedWalletNonce != nil {
      guard let jwsNonce = getValueForKey(
        from: jwt,
        key: ValidatedSiopOpenId4VPRequest.WALLET_NONCE_FORM_PARAM
      ) as? String else {
        throw ValidationError.validationError("nonce should not be nil")
      }
      
      guard jwsNonce == expectedWalletNonce else {
        throw ValidationError.validationError("nonce's do not match")
      }
    }
    
    guard let algorithm = jws.header.algorithm else {
      throw ValidationError.validationError("algorithm should not be nil")
    }
    
    guard jarConfiguration.supportedAlgorithms.contains(where: { $0.name == algorithm.rawValue }) else {
      throw ValidationError.validationError("nonce's do not match")
    }
  }
  
  func getValueForKey(from jwtString: String, key: String) -> Any? {
    do {
      let jwt = try JWS(compactSerialization: jwtString)
      let payloadData = jwt.payload.data()
      
      let jsonObject = try JSONSerialization.jsonObject(with: payloadData, options: [])
      guard let payloadDict = jsonObject as? [String: Any] else {
        return nil
      }
      return payloadDict[key]
      
    } catch {
      return nil
    }
  }
}

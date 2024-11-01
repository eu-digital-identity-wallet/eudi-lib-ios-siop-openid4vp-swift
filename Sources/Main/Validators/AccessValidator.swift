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
import JOSESwift
import X509

public actor AccessValidator {
  
  public let walletOpenId4VPConfig: SiopOpenId4VPConfiguration?
  private let resolver = WebKeyResolver()
  private let objectType: JOSEObjectType
  
  public init(
    walletOpenId4VPConfig: SiopOpenId4VPConfiguration?,
    objectType: JOSEObjectType = .REQ_JWT
  ) {
    self.walletOpenId4VPConfig = walletOpenId4VPConfig
    self.objectType = objectType
  }
  
  public func validate(clientId: String?, jwt: JWTString) async throws {
    let jwt = try JWS(compactSerialization: jwt)
    try await doValidate(clientId: clientId, jws: jwt)
  }
  
  private func doValidate(clientId: String?, jws: JWS) async throws {
    guard let dictionary = try JSONSerialization.jsonObject(with: jws.payload.data()) as? [String: Any] else {
      throw ValidatedAuthorizationError.validationError("Invalid JWS payload")
    }
    let claimSet = dictionary
    
    guard let clientId = clientId else {
      throw ValidatedAuthorizationError.missingRequiredField("client_id")
    }
    
    guard let jwtClientId = claimSet["client_id"] as? String else {
      throw ValidatedAuthorizationError.invalidClientId
    }
    
    guard clientId == jwtClientId else {
      throw ValidatedAuthorizationError.clientIdMismatch(clientId, jwtClientId)
    }
    
    guard let scheme = claimSet["client_id_scheme"] as? String else {
      throw ValidatedAuthorizationError.unsupportedClientIdScheme(nil)
    }
    
    guard let clientIdScheme = ClientIdScheme(rawValue: scheme) else {
      throw ValidatedAuthorizationError.unsupportedClientIdScheme(nil)
    }
    
    switch clientIdScheme {
    case .preRegistered:
      let supported: SupportedClientIdScheme? = walletOpenId4VPConfig?.supportedClientIdSchemes.first(where: { $0.scheme == clientIdScheme })
      try await validatePreregistered(
        supportedClientIdScheme: supported,
        clientId: clientId,
        jws: jws
      )
    case .x509SanUri:
      let supported: SupportedClientIdScheme? = walletOpenId4VPConfig?.supportedClientIdSchemes.first(where: { $0.scheme == clientIdScheme })
      try await validateX509(
        supportedClientIdScheme: supported,
        clientId: clientId,
        jws: jws,
        alternativeNames: { certificate in
          let alternativeNames = try? certificate
            .extensions
            .subjectAlternativeNames?
            .rawUniformResourceIdentifiers()
          return alternativeNames ?? []
        }
      )
    case .x509SanDns:
      let supported: SupportedClientIdScheme? = walletOpenId4VPConfig?.supportedClientIdSchemes.first(where: { $0.scheme == clientIdScheme })
      try await validateX509(
        supportedClientIdScheme: supported,
        clientId: clientId,
        jws: jws,
        alternativeNames: { certificate in
          let alternativeNames = try? certificate
            .extensions
            .subjectAlternativeNames?
            .rawSubjectAlternativeNames()
          return alternativeNames ?? []
        }
      )
    default: break
    }
  }
  
  private func validateX509(
    supportedClientIdScheme: SupportedClientIdScheme?,
    clientId: String,
    jws: JWS,
    alternativeNames: (Certificate) -> [String]
  ) async throws {
    
    let header = jws.header
    guard let chain: [String] = header.x5c else {
      throw ValidatedAuthorizationError.validationError("x5c header field does not contain a serialized leaf certificate")
    }
    
    let certificates: [Certificate] = parseCertificates(from: chain)

    guard !certificates.isEmpty else {
      throw ValidatedAuthorizationError.validationError("x5c header field does not contain a serialized leaf certificate")
    }
    
    switch supportedClientIdScheme {
    case .x509SanDns(let trust),
         .x509SanUri(let trust):
      let trust = trust(chain)
      if !trust {
        throw ValidatedAuthorizationError.validationError("Could not trust certificate chain")
      }
    default: throw ValidatedAuthorizationError.validationError("Invalid client id scheme for x509")
    }
    
    guard let leafCertificate = certificates.first else {
      throw ValidatedAuthorizationError.validationError("Could not locate leaf certificate")
    }

    let alternativeNames = alternativeNames(leafCertificate)
    if !alternativeNames.contains(clientId) {
      throw ValidatedAuthorizationError.validationError("Client id (\(clientId) not part of list (\(alternativeNames))")
    }
    
    let publicKey = leafCertificate.publicKey
    let pem = try publicKey.serializeAsPEM().pemString
    
    guard let signingAlgorithm = jws.header.algorithm else {
      throw ValidatedAuthorizationError.validationError("JWS header does not contain algorith field")
    }
    
    if let secKey = KeyController.convertPEMToPublicKey(pem, algorithm: signingAlgorithm) {
      let joseController = JOSEController()
      let verified = (try? joseController.verify(
        jws: jws,
        publicKey: secKey,
        algorithm: signingAlgorithm
      )) ?? false
      
      if !verified {
        throw ValidatedAuthorizationError.validationError("Unable to verify signature using public key from leaf certificate")
      }

    } else {
      throw ValidatedAuthorizationError.validationError("Unable to decode public key from leaf certificate")
    }
  }
  
  private func validatePreregistered(
    supportedClientIdScheme: SupportedClientIdScheme?,
    clientId: String,
    jws: JWS
  ) async throws {
    
    guard let supportedClientIdScheme = supportedClientIdScheme,
          supportedClientIdScheme.scheme == .preRegistered else {
      throw ValidatedAuthorizationError.unsupportedClientIdScheme(
        supportedClientIdScheme?.scheme.rawValue
      )
    }
    
    switch supportedClientIdScheme {
    case .preregistered(let clients):
      guard let client = clients[clientId] else {
        throw ValidatedAuthorizationError.validationError("Client with client_id \(clientId) is not pre-registered")
      }
      try await verifySignature(
        jws: jws,
        client: client
      )
    default: throw ValidatedAuthorizationError.unsupportedClientIdScheme(
      supportedClientIdScheme.scheme.rawValue
    )
    }
  }
  
  private func verifySignature(
    jws: JWS,
    client: PreregisteredClient
  ) async throws {
    
    if jws.header.typ != objectType.rawValue {
      throw ValidatedAuthorizationError.validationError("Header object type mismatch")
    }
    
    let jwk = await resolver.resolve(source: client.jwkSetSource)
    switch jwk {
    case .success(let set):
      guard let key = set?.keys.first,
            let algorithm = SignatureAlgorithm(rawValue: client.jarSigningAlg.name)
      else {
        throw ValidatedAuthorizationError.validationError("Could not resolve key from JWK source")
      }
      
      let publicKey = try RSAPublicKey(data: key.toDictionary().toThrowingJSONData())
      let secKey = try publicKey.converted(to: SecKey.self)
      if let verifier = Verifier(
        signatureAlgorithm: algorithm,
        key: secKey
      ) {
        let isValid = jws.isValid(for: verifier)
        if !isValid {
          throw ValidatedAuthorizationError.validationError("Unable to verify signature")
        }
        
      } else {
        throw ValidatedAuthorizationError.validationError("Unable to verify signature")
      }

    case .failure:
      throw ValidatedAuthorizationError.validationError("Could not resolve key from JWK source")
    }
  }
}

public extension AccessValidator {

  static func verifyJWS(jws: JWS, publicKey: SecKey) throws {

    let keyAttributes = SecKeyCopyAttributes(publicKey) as? [CFString: Any]
    let keyType = keyAttributes?[kSecAttrKeyType as CFString] as? String

    if keyType == (kSecAttrKeyTypeRSA as String) {
      if let verifier = Verifier(
        signatureAlgorithm: .RS256,
        key: publicKey
      ) {
        _ = try jws.validate(using: verifier)
        return
      }
    } else if keyType == (kSecAttrKeyTypeEC as String) {
      if let verifier = Verifier(
        signatureAlgorithm: .ES256,
        key: publicKey
      ) {
        _ = try jws.validate(using: verifier)
        return
      }
    }

    throw ValidatedAuthorizationError.validationError("Unable to verif JWS")
  }
}

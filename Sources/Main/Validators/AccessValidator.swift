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

public protocol AccessValidating: Sendable {
  func validate(clientId: String?, jwt: JWTString) async throws
}

public actor AccessValidator: AccessValidating {
  
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
    
    guard let clientId = clientId else {
      throw ValidationError.missingRequiredField("client_id")
    }
    
    guard
      let clientIdScheme = try? VerifierId.parse(clientId: clientId).get().scheme
    else {
      throw ValidationError.unsupportedClientIdScheme(nil)
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
      throw ValidationError.validationError("x5c header field does not contain a serialized leaf certificate")
    }
    
    let certificates: [Certificate] = parseCertificates(from: chain)

    guard !certificates.isEmpty else {
      throw ValidationError.validationError("x5c header field does not contain a serialized leaf certificate")
    }
    
    switch supportedClientIdScheme {
    case .x509SanDns(let trust),
         .x509SanUri(let trust):
      let trust = trust(chain)
      if !trust {
        throw ValidationError.validationError("Could not trust certificate chain")
      }
    default: throw ValidationError.validationError("Invalid client id scheme for x509")
    }
    
    guard let leafCertificate = certificates.first else {
      throw ValidationError.validationError("Could not locate leaf certificate")
    }

    let verifierId = VerifierId.parse(clientId: clientId)
    let alternativeNames = alternativeNames(leafCertificate)
    if let originalClientId = try? verifierId.get().originalClientId,
       !alternativeNames.contains(originalClientId) {
      throw ValidationError.validationError("Client id (\(clientId) not part of list (\(alternativeNames))")
    }
    
    let publicKey = leafCertificate.publicKey
    let pem = try publicKey.serializeAsPEM().pemString
    
    guard let signingAlgorithm = jws.header.algorithm else {
      throw ValidationError.validationError("JWS header does not contain algorith field")
    }
    
    if let secKey = KeyController.convertPEMToPublicKey(pem, algorithm: signingAlgorithm) {
      let joseController = JOSEController()
      let verified = (try? joseController.verify(
        jws: jws,
        publicKey: secKey,
        algorithm: signingAlgorithm
      )) ?? false
      
      if !verified {
        throw ValidationError.validationError("Unable to verify signature using public key from leaf certificate")
      }

    } else {
      throw ValidationError.validationError("Unable to decode public key from leaf certificate")
    }
  }
  
  private func validatePreregistered(
    supportedClientIdScheme: SupportedClientIdScheme?,
    clientId: String,
    jws: JWS
  ) async throws {
    
    guard let supportedClientIdScheme = supportedClientIdScheme,
          supportedClientIdScheme.scheme == .preRegistered else {
      throw ValidationError.unsupportedClientIdScheme(
        supportedClientIdScheme?.scheme.rawValue
      )
    }
    
    switch supportedClientIdScheme {
    case .preregistered(let clients):
      guard let client = clients[clientId] else {
        throw ValidationError.validationError("Client with client_id \(clientId) is not pre-registered")
      }
      try await verifySignature(
        jws: jws,
        client: client
      )
    default: throw ValidationError.unsupportedClientIdScheme(
      supportedClientIdScheme.scheme.rawValue
    )
    }
  }
  
  private func verifySignature(
    jws: JWS,
    client: PreregisteredClient
  ) async throws {
    
    if jws.header.typ != objectType.rawValue {
      throw ValidationError.validationError("Header object type mismatch")
    }
    
    let jwk = await resolver.resolve(source: client.jwkSetSource)
    switch jwk {
    case .success(let set):
      guard let key = set?.keys.first,
            let algorithm = SignatureAlgorithm(rawValue: client.jarSigningAlg.name)
      else {
        throw ValidationError.validationError("Could not resolve key from JWK source")
      }

      guard let secKey = self.key(for: key, and: algorithm) else {
        throw ValidationError.validationError("Unable to convert key to SecKey")
      }
      
      if let verifier = Verifier(
        signatureAlgorithm: algorithm,
        key: secKey
      ) {
        let isValid = jws.isValid(for: verifier)
        if !isValid {
          throw ValidationError.validationError("Unable to verify signature")
        }
        
      } else {
        throw ValidationError.validationError("Unable to verify signature")
      }

    case .failure:
      throw ValidationError.validationError("Could not resolve key from JWK source")
    }
  }
  
  private func key(for key: WebKeySet.Key, and algorithm: SignatureAlgorithm) -> SecKey? {
    switch algorithm {
    case .RS256, .RS384, .RS512:
      try? RSAPublicKey(data: key.toDictionary().toThrowingJSONData()).converted(to: SecKey.self)
    case .ES256, .ES384, .ES512:
      try? ECPublicKey(data: key.toDictionary().toThrowingJSONData()).converted(to: SecKey.self)
    case .HS256, .HS384, .HS512: nil
    case .PS256, .PS384, .PS512: nil
    }
  }
}

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
import Security
import JOSESwift
import PresentationExchange

public struct HolderInfo: Codable {
  public let email: String
  public let name: String
  
  public init(email: String, name: String) {
    self.email = email
    self.name = name
  }
}

public class JOSEController {
  
  public init() { }
  
  public func verify(jws: JWS, publicKey: SecKey) throws -> Bool {
    let verifier = try self.verifier(algorithhm: .RS256, publicKey: publicKey)
    return try jws.validate(using: verifier).isValid(for: verifier)
  }
  
  public func build<T: Codable>(
    request: ResolvedRequestData,
    holderInfo: T,
    walletConfiguration: WalletOpenId4VPConfiguration,
    rsaJWK: RSAPublicKey,
    signingKey: SecKey,
    ttl: TimeInterval = 600.0,
    kid: UUID = UUID()
  ) throws -> JWTString {
    
    var idTokenData: ResolvedRequestData.IdTokenData?
    switch request {
    case .idToken(request: let data):
      idTokenData = data
    default: throw JOSEError.notSupportedRequest
    }
    
    guard let idTokenData = idTokenData else {
      throw JOSEError.invalidIdTokenRequest
    }
    
    let subjectJwk = JWKSet(keys: [rsaJWK])
    let (iat, exp) = computeTokenDates(ttl: ttl)
    let issuerClaim = try buildIssuerClaim(
      walletConfiguration: walletConfiguration,
      rsaJWK: rsaJWK
    )
    
    // NOTE: By SIOPv2 draft 12 issuer = subject
    let claimSet = try ([
      JWTClaimNames.issuer: issuerClaim,
      JWTClaimNames.subject: issuerClaim,
      JWTClaimNames.audience: idTokenData.clientId,
      JWTClaimNames.issuedAt: Int(iat.timeIntervalSince1970.rounded()),
      JWTClaimNames.expirationTime: Int(exp.timeIntervalSince1970.rounded()),
      "sub_jwk": subjectJwk.toDictionary()
    ] as [String: Any])
      .merging(holderInfo.toDictionary(), uniquingKeysWith: { _, new in
        new
      })
      .toThrowingJSONData()
    
    return try sign(
      payload: Payload(claimSet),
      kid: kid,
      signingKey: signingKey
    )
  }
  
  public func getJWS(compactSerialization: String) throws -> JWS {
    guard let jws = try? JWS(compactSerialization: compactSerialization) else {
      throw JOSEError.invalidJWS
    }
    return jws
  }
}

private extension JOSEController {
  
  func verifier(algorithhm: SignatureAlgorithm, publicKey: SecKey) throws -> Verifier {
    guard let verifier = Verifier(verifyingAlgorithm: .RS256, key: publicKey) else {
      throw JOSEError.invalidVerifier
    }
    return verifier
  }
  
  func signer(algorithhm: SignatureAlgorithm, privateKey: SecKey) throws -> Signer<SecKey> {
    guard let signer = Signer(signingAlgorithm: algorithhm, key: privateKey) else {
      throw JOSEError.invalidSigner
    }
    return signer
  }
  
  func computeTokenDates(ttl: TimeInterval) -> (Date, Date) {
    let iat = Date()
    let exp = iat.addingTimeInterval(ttl)
    return (iat, exp)
  }
  
  func buildIssuerClaim(
    walletConfiguration: WalletOpenId4VPConfiguration,
    rsaJWK: RSAPublicKey
  ) throws -> String {
    switch walletConfiguration.preferredSubjectSyntaxType {
    case .jwkThumbprint:
      return try rsaJWK.thumbprint(algorithm: .SHA256)
    case .decentralizedIdentifier:
      return walletConfiguration.decentralizedIdentifier.stringValue
    }
  }
  
  func sign(
    payload: Payload,
    kid: UUID,
    signingKey: SecKey
  ) throws -> JWTString {
    let header = try JWSHeader(parameters: [
      "alg": SignatureAlgorithm.RS256.rawValue,
      "kid": kid.uuidString
    ])
    
    let signer = try self.signer(algorithhm: .RS256, privateKey: signingKey)
    
    return try JWS(
      header: header,
      payload: payload,
      signer: signer
    ).compactSerializedString
  }
}

public extension JOSEController {
  
  func generateHardcodedRSAPrivateKey() throws -> SecKey? {
    
    // Convert PEM key to Data
    guard
      let contents = String.loadStringFileFromBundle(
        named: "sample_derfile",
        withExtension: "der"
      )?.replacingOccurrences(of: "\n", with: ""),
      let data = Data(base64Encoded: contents)
    else {
      return nil
    }
    
    // Define the key attributes
    let attributes: [CFString: Any] = [
      kSecAttrKeyType: kSecAttrKeyTypeRSA,
      kSecAttrKeyClass: kSecAttrKeyClassPrivate
    ]
    
    // Create the SecKey object
    var error: Unmanaged<CFError>?
    guard let secKey = SecKeyCreateWithData(data as CFData, attributes as CFDictionary, &error) else {
      if let error = error?.takeRetainedValue() {
        print("Failed to create SecKey:", error)
      }
      return nil
    }
    return secKey
  }
  
  func generateRSAPrivateKey() throws -> SecKey {
    let attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
      kSecAttrKeySizeInBits as String: 2048
    ]
    
    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
      throw error!.takeRetainedValue() as Error
    }
    return privateKey
  }
  
  func generateRSAPublicKey(from privateKey: SecKey) throws -> SecKey {
    guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
      throw JOSEError.invalidPublicKey
    }
    return publicKey
  }
  
  func generateECDHPrivateKey() throws -> SecKey {
    let attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrKeySizeInBits as String: 256
    ]
    
    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
      throw error!.takeRetainedValue() as Error
    }
    return privateKey
  }
  
  func generateECDHPublicKey(from privateKey: SecKey) throws -> SecKey {
    guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
      throw NSError(domain: "YourDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate public key"])
    }
    return publicKey
  }
}

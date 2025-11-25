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

  public func verify(jws: JWS, publicKey: SecKey, algorithm: SignatureAlgorithm = .RS256) throws -> Bool {
    let verifier = try self.verifier(algorithhm: algorithm, publicKey: publicKey)
    return try jws.validate(using: verifier).isValid(for: verifier)
  }

  public func build<T: Codable>(
    resolvedRequest: ResolvedRequestData,
    holderInfo: T,
    walletConfiguration: OpenId4VPConfiguration,
    rsaJWK: RSAPublicKey,
    signingKey: SecKey,
    ttl: TimeInterval = 600.0,
    kid: UUID = UUID()
  ) throws -> JWTString {

    let vpTokenData: ResolvedRequestData.VpTokenData? = resolvedRequest.request
    guard let vpTokenData = vpTokenData else {
      throw JOSEError.notSupportedRequest
    }

    let subjectJwk = JWKSet(keys: [rsaJWK])
    let (iat, exp) = computeTokenDates(ttl: ttl)
    let issuerClaim = try buildIssuerClaim(
      walletConfiguration: walletConfiguration,
      rsaJWK: rsaJWK
    )

    let claimSet = try ([
      JWTClaimNames.issuer: issuerClaim,
      JWTClaimNames.subject: issuerClaim,
      JWTClaimNames.audience: vpTokenData.client.id.clientId,
      JWTClaimNames.issuedAt: Int(iat.timeIntervalSince1970.rounded()),
      JWTClaimNames.expirationTime: Int(exp.timeIntervalSince1970.rounded()),
      JWTClaimNames.subjectJWK: subjectJwk.toDictionary()
    ] as [String: Any?])
      .compactMapValues { $0 }
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
    guard let verifier = Verifier(
      signatureAlgorithm: algorithhm,
      key: publicKey
    ) else {
      throw JOSEError.invalidVerifier
    }
    return verifier
  }

  func signer(algorithhm: SignatureAlgorithm, privateKey: SecKey) throws -> Signer {
    guard let signer = Signer(
      signatureAlgorithm: algorithhm,
      key: privateKey
    ) else {
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
    walletConfiguration: OpenId4VPConfiguration,
    rsaJWK: RSAPublicKey
  ) throws -> String? {
    return try rsaJWK.thumbprint(algorithm: .SHA256)
  }

  func sign(
    payload: Payload,
    kid: UUID,
    signingKey: SecKey,
    algorithm: SignatureAlgorithm = .RS256
  ) throws -> JWTString {
    let header = try JWSHeader(parameters: [
      "alg": algorithm.rawValue,
      "kid": kid.uuidString
    ])

    let signer = try self.signer(algorithhm: algorithm, privateKey: signingKey)

    return try JWS(
      header: header,
      payload: payload,
      signer: signer
    ).compactSerializedString
  }
}

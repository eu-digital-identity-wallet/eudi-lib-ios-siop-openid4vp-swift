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
import XCTest
import JOSESwift

@testable import SiopOpenID4VP

final class JarJwtSignatureValidatorTests: XCTestCase {
  
  var validator: JarJwtSignatureValidator!
  
  override func tearDown() {
    DependencyContainer.shared.removeAll()
    self.validator = nil
    super.tearDown()
  }
  
  override func setUp() {
    overrideDependencies()
  }
  
  func testJarJwtSignature_WhenInputsAreValid_ThenAssertSuccess() async throws {
    
    self.validator = try? XCTUnwrap(JarJwtSignatureValidator(
      walletOpenId4VPConfig: preRegisteredWalletConfiguration()
    ))
    
    let walletConfig = await validator.walletOpenId4VPConfig!
    let algorithm = SignatureAlgorithm(rawValue: walletConfig.signingKeySet.keys.first!.alg!)!
    
    let clientId = "Verifier"
    let scheme = "pre-registered"
    let type = "oauth-authz-req+jwt"
    
    let jws = try JWS(
      header: .init(
        parameters: [
          "alg": algorithm.rawValue,
          "typ": type
        ]
      ),
      payload: try Payload([
        "client_id": clientId,
        "client_id_scheme": scheme
      ].toThrowingJSONData()),
      signer: Signer(
        signingAlgorithm: algorithm,
        key: walletConfig.signingKey
      )!
    )
    
    try await validator.validate(
      clientId: clientId,
      jwt: jws.compactSerializedString
    )
    
    XCTAssert(true)
  }
  
  func testJarJwtSignature_WhenInputsAreValidExceptClientId_ThenReturnFailure() async throws {
    
    self.validator = try! JarJwtSignatureValidator(
      walletOpenId4VPConfig: preRegisteredWalletConfiguration()
    )
    
    let walletConfig = await validator.walletOpenId4VPConfig!
    let algorithm = SignatureAlgorithm(rawValue: walletConfig.signingKeySet.keys.first!.alg!)!
    
    let clientId = "Verifier"
    let scheme = "pre-registered"
    
    let jws = try JWS(
      header: .init(
        algorithm: algorithm
      ),
      payload: try Payload([
        "client_id_scheme": scheme
      ].toThrowingJSONData()),
      signer: Signer(
        signingAlgorithm: algorithm,
        key: walletConfig.signingKey
      )!
    )
    
    do {
      try await validator.validate(
        clientId: clientId,
        jwt: jws.compactSerializedString
      )
    } catch {
      XCTAssert(error.localizedDescription == ValidatedAuthorizationError.invalidClientId.localizedDescription)
      return
    }
    
    XCTAssert(false)
  }
  
  func testJarJwtSignature_WhenInputsAreValidWithoutPregistered_ThenAssertSuccess() async throws {
    
    self.validator = try! JarJwtSignatureValidator(
      walletOpenId4VPConfig: iso509WalletConfiguration()
    )
    
    let walletConfig = await validator.walletOpenId4VPConfig!
    let algorithm = SignatureAlgorithm(rawValue: walletConfig.signingKeySet.keys.first!.alg!)!
    
    let clientId = "Verifier"
    let scheme = "iso_x509"
    
    let jws = try JWS(
      header: .init(
        algorithm: algorithm
      ),
      payload: try Payload([
        "client_id": clientId,
        "client_id_scheme": scheme
      ].toThrowingJSONData()),
      signer: Signer(
        signingAlgorithm: algorithm,
        key: walletConfig.signingKey
      )!
    )
    
    try await validator.validate(
      clientId: clientId,
      jwt: jws.compactSerializedString
    )
    
    XCTAssert(true)
  }
}

private extension JarJwtSignatureValidatorTests {
  
  func preRegisteredWalletConfiguration() throws -> WalletOpenId4VPConfiguration {
    
    let privateKey = try KeyController.generateRSAPrivateKey()
    let publicKey = try KeyController.generateRSAPublicKey(from: privateKey)
    
    let alg = JWSAlgorithm(.RS256)
    let publicKeyJWK = try RSAPublicKey(
      publicKey: publicKey,
      additionalParameters: [
        "alg": alg.name,
        "use": "sig",
        "kid": UUID().uuidString
      ])
    
    let keySet = try WebKeySet([
      "keys": [publicKeyJWK.jsonString()?.convertToDictionary()]
    ])
    
    return WalletOpenId4VPConfiguration(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123"),
      signingKey: privateKey,
      signingKeySet: keySet,
      supportedClientIdSchemes: [
        .isoX509,
        .preregistered(clients: [
          "Verifier": .init(
            clientId: "Verifier",
            jarSigningAlg: JWSAlgorithm(.RS256),
            jwkSetSource: .passByValue(webKeys: .init(keys: keySet.keys))
          )
        ])],
      vpFormatsSupported: []
    )
  }
  
  func iso509WalletConfiguration() throws -> WalletOpenId4VPConfiguration {
    
    let privateKey = try KeyController.generateRSAPrivateKey()
    let publicKey = try KeyController.generateRSAPublicKey(from: privateKey)
    
    let alg = JWSAlgorithm(.RS256)
    let publicKeyJWK = try RSAPublicKey(
      publicKey: publicKey,
      additionalParameters: [
        "alg": alg.name,
        "use": "sig",
        "kid": UUID().uuidString
      ])
    
    let keySet = try WebKeySet([
      "keys": [publicKeyJWK.jsonString()?.convertToDictionary()]
    ])
    
    return WalletOpenId4VPConfiguration(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123"),
      signingKey: privateKey,
      signingKeySet: keySet,
      supportedClientIdSchemes: [
        .isoX509,
        .preregistered(clients: [
          "Verifier": .init(
            clientId: "Verifier",
            jarSigningAlg: JWSAlgorithm(.RS256),
            jwkSetSource: .passByValue(webKeys: .init(keys: keySet.keys))
          )
        ])],
      vpFormatsSupported: []
    )
  }
  
  func overrideDependencies() {
    DependencyContainer.shared.register(type: Reporting.self, dependency: {
      Reporter()
    })
  }
}

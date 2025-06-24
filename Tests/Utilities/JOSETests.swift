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
import XCTest
import JOSESwift

@testable import SiopOpenID4VP

final class JOSETests: DiXCTest {

  func testJOSEBuildTokenGivenValidRequirements() async throws {

    let kid = UUID()
    let jose = JOSEController()

    let privateKey = try KeyController.generateHardcodedRSAPrivateKey()
    let publicKey = try KeyController.generateRSAPublicKey(from: privateKey!)
    let rsaJWK = try RSAPublicKey(
      publicKey: publicKey,
      additionalParameters: [
        "use": "sig",
        "kid": kid.uuidString
      ])

    let holderInfo: HolderInfo = .init(
      email: "email@example.com",
      name: "Bob"
    )

    let keySet = try WebKeySet(jwk: rsaJWK)
    let publicKeysURL = URL(string: "\(TestsConstants.host)/wallet/public-keys.json")!

    let walletConfiguration: SiopOpenId4VPConfiguration = .init(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123"),
      signingKey: privateKey!,
      signingKeySet: keySet,
      supportedClientIdSchemes: [
        .preregistered(clients: [
          "verifier-backend.eudiw.dev": .init(
            clientId: "verifier-backend.eudiw.dev",
            legalName: "Verifier",
            jarSigningAlg: .init(.RS256),
            jwkSetSource: .fetchByReference(url: publicKeysURL)
          )
        ])
      ],
      vpFormatsSupported: [],
      jarmConfiguration: .default(
        .init(
          privateKey: privateKey!,
          webKeySet: keySet
        )
      )
    )

    let unvalidatedRequest = UnvalidatedRequest.make(
      from: TestsConstants.validIdTokenByClientByValuePresentationByReferenceUrl.absoluteString
    )

    let resolver = AuthorizationRequestResolver()
    let request = try await resolver.resolve(
      walletConfiguration: walletConfiguration,
      unvalidatedRequest: unvalidatedRequest.get()
    )

    switch request {
    case .notSecured(let data):
      let jws = try jose.build(
        request: data,
        holderInfo: holderInfo,
        walletConfiguration: walletConfiguration,
        rsaJWK: rsaJWK,
        signingKey: privateKey!,
        kid: kid
      )
      XCTAssert(try jose.verify(jws: jose.getJWS(compactSerialization: jws), publicKey: publicKey))
    default:
      XCTAssert(false)
    }
  }
}

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
import PresentationExchange

@testable import SiopOpenID4VP

final class SiopOpenID4VPTests: DiXCTest {

  func preRegisteredWalletConfiguration() throws -> SiopOpenId4VPConfiguration {

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

    return SiopOpenId4VPConfiguration(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123"),
      signingKey: privateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .preregistered(clients: [
          "verifier-backend.eudiw.dev": .init(
            clientId: "verifier-backend.eudiw.dev",
            legalName: "verifier-backend.eudiw.dev",
            jarSigningAlg: JWSAlgorithm(.RS256),
            jwkSetSource: .passByValue(webKeys: .init(keys: [
              .init(
                kty: "RSA",
                use: "sig",
                kid: "6b011ae0-86cb-4732-9039-fb918875898c",
                iat: 1691502634,
                crv: "",
                x: "",
                y: "",
                exponent: "AQAB",
                modulus: "qT-f2yAL1pA-AFNYusDrkfJPZ9AGJT8-xfqszP90-i6wOd7vTf-OPtMjElZ6i2XpBJcbAX8ICjFn7Q2TeAyGeBieKRgXYd1ry18ae7bOu6lE_s7yg-O5PE4s1ZpTRl1W1RRcOo8ZICA0lGaucgn5eDMZqwBYyepIcndUlIWggeUJvekaZBsvBLe6RTEC_6OLiP-VZOu6F-jor69_J9Y5QzDGu3p27-LwcSpjy1i_cwDb9QzYqyPT3k72wmHIoHEgzVR32Y6E-LUSmJX7GZJ9MQNraf6ch-_Mg1pDZqlnSdK6XNLodU8YxelUIc9aAWKLxUFnSlUWjyqN-dDHBLgY9Q",
                alg: "RS256"
              )
            ]))
          ),
          "Verifier": .init(
            clientId: "Verifier",
            legalName: "Verifier",
            jarSigningAlg: JWSAlgorithm(.RS256),
            jwkSetSource: .passByValue(webKeys: .init(keys: [
              .init(
                kty: "RSA",
                use: "sig",
                kid: "6b011ae0-86cb-4732-9039-fb918875898c",
                iat: 1691502634,
                crv: "",
                x: "",
                y: "",
                exponent: "AQAB",
                modulus: "qT-f2yAL1pA-AFNYusDrkfJPZ9AGJT8-xfqszP90-i6wOd7vTf-OPtMjElZ6i2XpBJcbAX8ICjFn7Q2TeAyGeBieKRgXYd1ry18ae7bOu6lE_s7yg-O5PE4s1ZpTRl1W1RRcOo8ZICA0lGaucgn5eDMZqwBYyepIcndUlIWggeUJvekaZBsvBLe6RTEC_6OLiP-VZOu6F-jor69_J9Y5QzDGu3p27-LwcSpjy1i_cwDb9QzYqyPT3k72wmHIoHEgzVR32Y6E-LUSmJX7GZJ9MQNraf6ch-_Mg1pDZqlnSdK6XNLodU8YxelUIc9aAWKLxUFnSlUWjyqN-dDHBLgY9Q",
                alg: "RS256"
              )
            ]))
          )
        ])
      ],
      vpFormatsSupported: [],
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: VPConfiguration.default(),
      jarmConfiguration: .default(
        .init(
          privateKey: privateKey,
          webKeySet: keySet
        )
      )
    )
  }

  static func preRegisteredWalletConfigurationWithKnownClientID(
    _ clientId: String = "verifier-backend.eudiw.dev"
  ) throws -> SiopOpenId4VPConfiguration {

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

    return SiopOpenId4VPConfiguration(
      subjectSyntaxTypesSupported: [
        .decentralizedIdentifier,
        .jwkThumbprint
      ],
      preferredSubjectSyntaxType: .jwkThumbprint,
      decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123"),
      signingKey: privateKey,
      publicWebKeySet: keySet,
      supportedClientIdSchemes: [
        .preregistered(clients: [
          clientId: .init(
            clientId: clientId,
            legalName: "Verifier",
            jarSigningAlg: JWSAlgorithm(.RS256),
            jwkSetSource: .passByValue(webKeys: .init(keys: [
              .init(
                kty: "RSA",
                use: "sig",
                kid: "6b011ae0-86cb-4732-9039-fb918875898c",
                iat: 1691502634,
                crv: "",
                x: "",
                y: "",
                exponent: "AQAB",
                modulus: "qT-f2yAL1pA-AFNYusDrkfJPZ9AGJT8-xfqszP90-i6wOd7vTf-OPtMjElZ6i2XpBJcbAX8ICjFn7Q2TeAyGeBieKRgXYd1ry18ae7bOu6lE_s7yg-O5PE4s1ZpTRl1W1RRcOo8ZICA0lGaucgn5eDMZqwBYyepIcndUlIWggeUJvekaZBsvBLe6RTEC_6OLiP-VZOu6F-jor69_J9Y5QzDGu3p27-LwcSpjy1i_cwDb9QzYqyPT3k72wmHIoHEgzVR32Y6E-LUSmJX7GZJ9MQNraf6ch-_Mg1pDZqlnSdK6XNLodU8YxelUIc9aAWKLxUFnSlUWjyqN-dDHBLgY9Q",
                alg: "RS256"
              )
            ]))
          )
        ])],
      vpFormatsSupported: [],
      jarConfiguration: .noEncryptionOption,
      vpConfiguration: VPConfiguration.default(),
      jarmConfiguration: .default(
        .init(
          privateKey: privateKey,
          webKeySet: keySet
        )
      )
    )
  }

  // MARK: - Presentation submission test

  func testPresentationSubmissionJsonStringDecoding() throws {

    let definition = try? XCTUnwrap(Dictionary.from(
      bundle: "presentation_submission_example"
    ).get().toJSONString())

    let result: Result<PresentationSubmissionContainer, ParserError> = Parser().decode(json: definition!)

    let container = try! result.get()

    XCTAssert(container.submission.id == "a30e3b91-fb77-4d22-95fa-871689c322e2")
  }

  // MARK: - Authorisation Request Testing

  func testAuthorizationRequestDataGivenValidDataInURL() throws {
    let authorizationRequestData = UnvalidatedRequestObject(from: TestsConstants.validAuthorizeUrl)
    XCTAssertNotNil(authorizationRequestData)
  }

  func testAuthorizationRequestDataGivenInvalidInput() throws {

    let parser = Parser()
    let result: Result<UnvalidatedRequestObject, ParserError> = parser.decode(
      path: "input_descriptors_example",
      type: "json"
    )

    let container = try? result.get()
    XCTAssertNotNil(container)
  }

  func testSDKValidationResolutionGivenDataByValueIsValid() async throws {

    let walletConfiguration = try Self.preRegisteredWalletConfigurationWithKnownClientID()
    let request = try UnvalidatedRequest.make(from: TestsConstants.validAuthorizeUrl.absoluteString).get()
    switch request {
    case .plain(let object):
      let source = try await RequestAuthenticator(
        config: walletConfiguration,
        clientAuthenticator: .init(config: walletConfiguration)
      ).parseQuerySource(requestObject: object)

      switch source {
      case .byPresentationDefinitionSource(let source):
        let resolver = await PresentationDefinitionResolver().resolve(
          source: source
        )

        switch resolver {
        case .success(let presentationDefinition):
          XCTAssert(presentationDefinition.id == "8e6ad256-bd03-4361-a742-377e8cccced0")
          XCTAssert(presentationDefinition.inputDescriptors.count == 1)

          return
        case .failure: break
        }
        default: break
      }
      default: break

    }

    XCTAssert(false)
  }

  func testAuthorize_WhenWalletConfigurationIsNil_ReturnsInvalidResolutionWithMissingConfig() async {
    let siop = SiopOpenID4VP(walletConfiguration: nil)
    let url = URL(string: "https://example.com/valid-request")!
    let result = await siop.authorize(url: url)

    switch result {
    case .invalidResolution(let error, let dispatchDetails):

      if case ValidationError.nonDispatchable(let innerError) = error {
        if case ValidationError.missingConfiguration = innerError {
          XCTAssertTrue(true)
        } else {
          XCTFail("Expected inner error to be missingConfiguration")
        }
      } else {
        XCTFail("Expected error to be nonDispatchable")
      }

      XCTAssertNil(dispatchDetails, "dispatchDetails should be nil")

    default:
      XCTFail("Expected invalidResolution but got \(result)")
    }
  }

  // MARK: - Resolved Validated Authorisation Request Testing

  func testIdVpTokenValidationResolutionGivenReferenceDataIsValid() async throws {

    let walletConfiguration = try Self.preRegisteredWalletConfigurationWithKnownClientID()

    do {
      let unvalidatedRequest = UnvalidatedRequest.make(
        from: TestsConstants.validIdVpTokenByClientByValuePresentationByReferenceUrl.absoluteString
      )

      let resolver = AuthorizationRequestResolver()
      let request = try await resolver.resolve(
        walletConfiguration: walletConfiguration,
        unvalidatedRequest: unvalidatedRequest.get()
      )

      let resolved = request.resolved
      switch resolved {
      case .idAndVpToken(let request):
        XCTAssertEqual(request.clientMetaData!.vpFormats.values.first!, VpFormat.sdJwtVc(sdJwtAlgorithms: [JWSAlgorithm(.ES256)], kbJwtAlgorithms: [JWSAlgorithm(.ES256)]))
        XCTAssert(true)
      default:
        XCTAssert(false, "Unexpected case")
      }
    } catch _ as FetchError {
      XCTAssert(true)
    } catch {
      XCTAssert(false)
    }
  }

  func testIdTokenValidationResolutionGivenReferenceDataIsValid() async throws {

    let walletConfiguration = try Self.preRegisteredWalletConfigurationWithKnownClientID()

    let unvalidatedRequest = UnvalidatedRequest.make(
      from: TestsConstants.validIdTokenByClientByValuePresentationByReferenceUrl.absoluteString
    )

    let resolver = AuthorizationRequestResolver()
    let request = try await resolver.resolve(
      walletConfiguration: walletConfiguration,
      unvalidatedRequest: unvalidatedRequest.get()
    )

    let resolved = request.resolved
    switch resolved {
    case .idToken:
      XCTAssert(true)
    default:
      XCTAssert(false, "Unexpected case")
    }
  }

  func testValidationResolutionGivenReferenceDataIsValid() async throws {

    let walletConfiguration = try Self.preRegisteredWalletConfigurationWithKnownClientID()

    let unvalidatedRequest = UnvalidatedRequest.make(
      from: TestsConstants.validVpTokenByClientByValuePresentationByReferenceUrl.absoluteString
    )

    let resolver = AuthorizationRequestResolver()
    let request = try await resolver.resolve(
      walletConfiguration: walletConfiguration,
      unvalidatedRequest: unvalidatedRequest.get()
    )

    let resolved = request.resolved
    XCTAssertNotNil(resolved)
  }

  func testValidationResolutionWithAuthorisationRequestGivenDataIsValid() async throws {

    let walletConfiguration = try Self.preRegisteredWalletConfigurationWithKnownClientID()

    let unvalidatedRequest = UnvalidatedRequest.make(
      from: TestsConstants.validVpTokenByClientByValuePresentationByReferenceUrl.absoluteString
    )

    let resolver = AuthorizationRequestResolver()
    let request = try await resolver.resolve(
      walletConfiguration: walletConfiguration,
      unvalidatedRequest: unvalidatedRequest.get()
    )

    let resolved = request.resolved

    XCTAssertNotNil(resolved)
  }

  // MARK: - Invalid data Testing

  func testAuthorisationValidationGivenDataIsInvalid() async throws {

    let walletConfiguration = try Self.preRegisteredWalletConfigurationWithKnownClientID()

    let unvalidatedRequest = UnvalidatedRequest.make(
      from: TestsConstants.invalidUrl.absoluteString
    )

    let resolver = AuthorizationRequestResolver()
    let request = try await resolver.resolve(
      walletConfiguration: walletConfiguration,
      unvalidatedRequest: unvalidatedRequest.get()
    )

    switch request {
    case .notSecured:
      XCTAssert(false)
    case .jwt:
      XCTAssert(false)
    case .invalidResolution:
      XCTAssert(true)
    }
  }

  func testRequestObjectGivenValidJWT() async throws {

    let walletConfiguration = try preRegisteredWalletConfiguration()

    let unvalidatedRequest = UnvalidatedRequest.make(
      from: TestsConstants.validVpTokenByClientByValuePresentationByReferenceUrl.absoluteString
    )

    let resolver = AuthorizationRequestResolver()
    let request = try await resolver.resolve(
      walletConfiguration: walletConfiguration,
      unvalidatedRequest: unvalidatedRequest.get()
    )

    let resolved = request.resolved

    switch resolved! {
    case .vpToken:
      XCTAssert(true)
    default:
      XCTAssert(false)
    }
  }

  func testRequestObjectGivenValidJWTUri() async throws {

    let walletConfiguration = try preRegisteredWalletConfiguration()

    let unvalidatedRequest = UnvalidatedRequest.make(
      from: TestsConstants.validVpTokenByClientByValuePresentationByReferenceUrl.absoluteString
    )

    let resolver = AuthorizationRequestResolver()
    let request = try await resolver.resolve(
      walletConfiguration: walletConfiguration,
      unvalidatedRequest: unvalidatedRequest.get()
    )

    let resolved = request.resolved

    XCTAssertNotNil(resolved)

    switch resolved {
    case .vpToken, .idToken:
      XCTAssert(true)
    default:
      XCTAssert(false)
    }
  }

  func testSDKValidationResolutionGivenDataRequestObjectByValueIsValid() async throws {

    let walletConfiguration = try preRegisteredWalletConfiguration()
    let unvalidatedRequest = UnvalidatedRequest.make(
      from: TestsConstants.requestObjectUrl.absoluteString
    )

    let resolver = AuthorizationRequestResolver()
    let request = try await resolver.resolve(
      walletConfiguration: walletConfiguration,
      unvalidatedRequest: unvalidatedRequest.get()
    )

    let resolved = request.resolved

    XCTAssertNotNil(resolved)
  }

  func testSDKValidationResolutionGivenDataRequestObjectByReferenceIsNotFoundURL() async throws {

    let walletConfiguration = try preRegisteredWalletConfiguration()
    let unvalidatedRequest = UnvalidatedRequest.make(
      from: TestsConstants.requestExpiredUrl.absoluteString
    )

    let resolver = AuthorizationRequestResolver()

    do {
      _ = try await resolver.resolve(
        walletConfiguration: walletConfiguration,
        unvalidatedRequest: unvalidatedRequest.get()
      )
    } catch _ as FetchError {
      XCTAssert(true)
    }
  }
}

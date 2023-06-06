import Foundation

import XCTest
import JSONSchema
import Sextant
import Mockingbird
import JOSESwift

@testable import SiopOpenID4VP

final class DirectPostTests: XCTestCase {
  
  override func setUp() async throws {
    overrideDependencies()
    try await super.setUp()
  }
  
  override func tearDown() {
    DependencyContainer.shared.removeAll()
    super.tearDown()
  }
  
  func testValidDirectPostAuthorisationResponseGivenValidResolutionAndConsent() {
    
    // Obtain an id token resolution
    let resolved: ResolvedRequestData = .idToken(
      request: .init(
        idTokenType: .attesterSigned,
        clientMetaData: Constants.testClientMetaData(),
        clientId: Constants.testClientId,
        nonce: Constants.testNonce,
        responseMode: Constants.testResponseMode,
        state: Constants.generateRandomBase64String(),
        scope: Constants.testScope
      )
    )
    
    // Generate a random JWT
    let jwt = Constants.generateRandomJWT()
    
    // Obtain consent
    let consent: ClientConsent = .idToken(idToken: jwt)
    
    // Generate a direct post authorisation response
    let response = try? AuthorizationResponse(
      resolvedRequest: resolved,
      consent: consent
    )
    
    XCTAssertNotNil(response)
  }
  
  func testExpectedErrorGivenValidResolutionAndNegaticeConsent() {
    
    // Obtain an id token resolution
    let resolved: ResolvedRequestData = .idToken(
      request: .init(
        idTokenType: .attesterSigned,
        clientMetaData: Constants.testClientMetaData(),
        clientId: Constants.testClientId,
        nonce: Constants.testNonce,
        responseMode: Constants.testResponseMode,
        state: Constants.generateRandomBase64String(),
        scope: Constants.testScope
      )
    )
    
    // Do not obtain consent
    let consent: ClientConsent = .negative
    
    do {
      // Generate an error since consent was not given
      _ = try AuthorizationResponse(
        resolvedRequest: resolved,
        consent: consent
      )
    } catch ValidatedAuthorizationError.negativeConsent {
      XCTAssert(true)
      return
    } catch {
      print(error.localizedDescription)
      XCTAssert(false)
    }
    
    XCTAssert(false)
  }
  
  func testPostDirectPostAuthorisationResponseGivenValidResolutionAndConsent() async throws {
    
    // Obtain an id token resolution
    let resolved: ResolvedRequestData = .idToken(
      request: .init(
        idTokenType: .attesterSigned,
        clientMetaData: Constants.testClientMetaData(),
        clientId: Constants.testClientId,
        nonce: Constants.testNonce,
        responseMode: Constants.testResponseMode,
        state: Constants.generateRandomBase64String(),
        scope: Constants.testScope
      )
    )
    
    let kid = UUID()
    let jose = JOSEController()
    
    let privateKey = try jose.generateHardcodedPrivateKey()
    let publicKey = try jose.generatePublicKey(from: privateKey!)
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
    
    let jws = try jose.build(
      request: resolved,
      holderInfo: holderInfo,
      walletConfiguration: .init(
        subjectSyntaxTypesSupported: [
          .decentralizedIdentifier,
          .jwkThumbprint
        ],
        preferredSubjectSyntaxType: .jwkThumbprint,
        decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123456789abcdefghi"),
        supportedClientIdScheme: .did,
        vpFormatsSupported: []
      ),
      rsaJWK: rsaJWK,
      signingKey: privateKey!,
      kid: kid
    )
    
    XCTAssert(try jose.verify(jws: jose.getJWS(compactSerialization: jws), publicKey: publicKey))
    
    // Obtain consent
    let consent: ClientConsent = .idToken(idToken: jws)
    
    // Generate a direct post authorisation response
    let response = try? AuthorizationResponse(
      resolvedRequest: resolved,
      consent: consent
    )
    
    XCTAssertNotNil(response)

    let service = mock(AuthorisationServiceType.self)
    let dispatcher = Dispatcher(service: service, authorizationResponse: response!)
    await given(service.post(poster: any(), response: any())) ~> DirectPostResponse()
    let result: DirectPostResponse = try await dispatcher.dispatch(response: response!)
    
    XCTAssertNotNil(result)
  }
}

private extension DirectPostTests {
  func overrideDependencies() {
    DependencyContainer.shared.register(type: Reporting.self, dependency: {
      MockReporter()
    })
  }
}

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
    let consent: ClientConsent = .negative(message: "user_cancelled")
    
    do {
      // Generate an error since consent was not given
      let response = try AuthorizationResponse(
        resolvedRequest: resolved,
        consent: consent
      )
      
      switch response {
      case .directPost(_, data: let data):
        switch data {
        case .noConsensusResponseData(state: let state, error: _):
          XCTAssert(true, state)
          return
        default: XCTAssert(false, "Incorrect response type")
        }
      default: XCTAssert(false, "Incorrect response type")
      }
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
    await given(service.formCheck(poster: any(), response: any())) ~> true
    let result: DispatchOutcome = try await dispatcher.dispatch()
    
    XCTAssertNotNil(result)
  }
  
  func testPostDirectPostAuthorisationResponseGivenValidResolutionAndNegativeConsent() async throws {
    
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
    let consent: ClientConsent = .negative(message: "user_cancelled")
    
    // Generate a direct post authorisation response
    let response = try? AuthorizationResponse(
      resolvedRequest: resolved,
      consent: consent
    )
    
    XCTAssertNotNil(response)

    let service = mock(AuthorisationServiceType.self)
    let dispatcher = Dispatcher(service: service, authorizationResponse: response!)
    await given(service.formCheck(poster: any(), response: any())) ~> true
    let result: DispatchOutcome = try await dispatcher.dispatch()
    
    XCTAssertNotNil(result)
  }

  func testSDKEndtoEndDirectPost() async throws {
    
    let sdk = SiopOpenID4VP()
    
    overrideDependencies()
    let r = try await sdk.authorize(url: URL(string: "eudi-wallet://authorize?client_id=Verifier&request_uri=http://localhost:8080/wallet/request.jwt/Kv41uoRrIXPqnCiw-3TxA-WHNlIqeBbKPneavFRhgc_6pRuqeAOJrUZ9ACsRjBDg6Pm-KeI7Z2gjnXLEaEe82A")!)
    
    switch r {
    case .oauth2: break
    case .jwt(request: let request):
      let resolved = request
      
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
      
      let result: DispatchOutcome = try await sdk.dispatch(response: response!)
      
      XCTAssertTrue(result == .accepted(redirectURI: nil))
    }
  }
}

private extension DirectPostTests {
  func overrideDependencies() {
    DependencyContainer.shared.register(type: Reporting.self, dependency: {
      MockReporter()
    })
  }
}

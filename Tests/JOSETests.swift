import XCTest
import JSONSchema
import Sextant
import JOSESwift

@testable import SiopOpenID4VP

final class JOSETests: XCTestCase {
  
  override func setUp() async throws {
    overrideDependencies()
    try await super.setUp()
  }

  override func tearDown() {
    DependencyContainer.shared.removeAll()
    super.tearDown()
  }
  
  func testJOSEBuildTokenGivenValidRequirements() async throws {
    
    let authorizationRequestData = AuthorizationRequestUnprocessedData(from: TestsConstants.validIdTokenByClientByValuePresentationByReferenceUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let validatedAuthorizationRequestData = try? await ValidatedSiopOpenId4VPRequest(authorizationRequestData: authorizationRequestData!)
    
    XCTAssertNotNil(validatedAuthorizationRequestData)
    
    let resolvedSiopOpenId4VPRequestData = try? await ResolvedRequestData(clientMetaDataResolver: ClientMetaDataResolver(), presentationDefinitionResolver: PresentationDefinitionResolver(), validatedAuthorizationRequest: validatedAuthorizationRequestData!)
    
    XCTAssertNotNil(resolvedSiopOpenId4VPRequestData)
    
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
      request: resolvedSiopOpenId4VPRequestData!,
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
  }
}

private extension JOSETests {
  func overrideDependencies() {
    DependencyContainer.shared.register(type: Reporting.self, dependency: {
      Reporter()
    })
  }
}

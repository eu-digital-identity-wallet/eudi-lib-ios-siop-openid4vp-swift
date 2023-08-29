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
import Combine
import XCTest
import JOSESwift
import PresentationExchange

@testable import SiopOpenID4VP

final class SiopOpenID4VPTests: DiXCTest {
  
  var subscriptions = Set<AnyCancellable>()
  
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
      decentralizedIdentifier: try DecentralizedIdentifier(rawValue: "did:example:123456789abcdefghi"),
      signingKey: privateKey,
      signingKeySet: keySet,
      supportedClientIdSchemes: [
        .isoX509,
        .preregistered(clients: [
          "Verifier": .init(
            clientId: "Verifier",
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
      vpFormatsSupported: []
    )
  }
  
  // MARK: - Presentation submission test
  
  func testPresentationSubmissionJsonStringDecoding() throws {
    
    let definition = try! Dictionary.from(
      bundle: "presentation_submission_example"
    ).get().toJSONString()!
    
    let result: Result<PresentationSubmissionContainer, ParserError> = Parser().decode(json: definition)
    
    let container = try! result.get()
    
    XCTAssert(container.submission.id == "a30e3b91-fb77-4d22-95fa-871689c322e2")
  }
  
  // MARK: - Authorisation Request Testing
  
  func testAuthorizationRequestDataGivenValidDataInURL() throws {
    let authorizationRequestData = AuthorisationRequestObject(from: TestsConstants.validAuthorizeUrl)
    XCTAssertNotNil(authorizationRequestData)
  }
  
  func testAuthorizationRequestDataGivenInvalidInput() throws {
    
    let parser = Parser()
    let result: Result<AuthorisationRequestObject, ParserError> = parser.decode(
      path: "input_descriptors_example",
      type: "json"
    )
    
    let container = try? result.get()
    XCTAssertNotNil(container)
  }
  
  func testSDKValidationResolutionGivenDataByValueIsValid() async throws {
    
    let sdk = SiopOpenID4VP()
    let presentationDefinition: PresentationDefinition = try await sdk.process(url: TestsConstants.validAuthorizeUrl)
    
    XCTAssert(presentationDefinition.id == "8e6ad256-bd03-4361-a742-377e8cccced0")
    XCTAssert(presentationDefinition.inputDescriptors.count == 1)
  }
  
  func testSDKValidationResolutionGivenDataByReferenceIsValid() async throws {
    
    let sdk = SiopOpenID4VP()
    
    overrideDependencies()
    
    do {
      let presentationDefinition = try await sdk.process(url: TestsConstants.validByReferenceAuthorizeUrl)
      
      XCTAssert(presentationDefinition.id == "32f54163-7166-48f1-93d8-ff217bdb0653")
      XCTAssert(presentationDefinition.inputDescriptors.count == 1)
    } catch _ as FetchError {
      XCTAssert(true)
    } catch {
      
    }
  }
  
  func testSDKValidationResolutionGivenDataIsInvalid() async throws {
    
    let sdk = SiopOpenID4VP()
    
    do {
      _ = try await sdk.process(url: TestsConstants.invalidAuthorizeUrl)
    } catch {
      XCTAssert(true, error.localizedDescription)
      return
    }
    
    XCTAssert(false)
  }
  
  func testSDKValidationResolutionAndDoNotMatchGivenDataByValueIsValid() async throws {
    
    let sdk = SiopOpenID4VP()
    let passportClaim = Claim(
      id: "samplePassport",
      format: .ldp,
      jsonObject: [
        "credentialSchema":
          [
            "id": "hub://did:foo:123/Collections/schema.us.gov/passport.json"
          ],
        "credentialSubject":
          [
            "birth_date":"1974-02-11",
          ]
      ]
    )
    
    let presentationDefinition = try await sdk.process(url: TestsConstants.validAuthorizeUrl)
    let match = sdk.match(presentationDefinition: presentationDefinition, claims: [passportClaim])
    
    XCTAssert(presentationDefinition.id == "8e6ad256-bd03-4361-a742-377e8cccced0")
    XCTAssert(presentationDefinition.inputDescriptors.count == 1)
    
    if case .notMatched = match {
      XCTAssert(true)
      
    } else {
      XCTFail("wrong match")
    }
  }
  
  // MARK: - Resolved Validated Authorisation Request Testing
  
  func testIdVpTokenValidationResolutionGivenReferenceDataIsValid() async throws {
    
    let authorizationRequestData = AuthorisationRequestObject(from: TestsConstants.validIdVpTokenByClientByValuePresentationByReferenceUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    do {
      let validatedAuthorizationRequestData = try await ValidatedSiopOpenId4VPRequest(authorizationRequestData: authorizationRequestData!)
      
      XCTAssertNotNil(validatedAuthorizationRequestData)
      
      let resolvedSiopOpenId4VPRequestData = try await ResolvedRequestData(clientMetaDataResolver: ClientMetaDataResolver(), presentationDefinitionResolver: PresentationDefinitionResolver(), validatedAuthorizationRequest: validatedAuthorizationRequestData)
      
      XCTAssertNotNil(resolvedSiopOpenId4VPRequestData)
    } catch _ as FetchError {
      XCTAssert(true)
    } catch {
      
    }
  }
  
  func testIdTokenValidationResolutionGivenReferenceDataIsValid() async throws {
    
    let authorizationRequestData = AuthorisationRequestObject(from: TestsConstants.validIdTokenByClientByValuePresentationByReferenceUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let validatedAuthorizationRequestData = try? await ValidatedSiopOpenId4VPRequest(authorizationRequestData: authorizationRequestData!)
    
    XCTAssertNotNil(validatedAuthorizationRequestData)
    
    let resolvedSiopOpenId4VPRequestData = try? await ResolvedRequestData(clientMetaDataResolver: ClientMetaDataResolver(), presentationDefinitionResolver: PresentationDefinitionResolver(), validatedAuthorizationRequest: validatedAuthorizationRequestData!)
    
    XCTAssertNotNil(resolvedSiopOpenId4VPRequestData)
  }
  
  func testValidationResolutionGivenReferenceDataIsValid() async throws {
    
    let authorizationRequestData = AuthorisationRequestObject(from: TestsConstants.validVpTokenByClientByValuePresentationByReferenceUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let validatedAuthorizationRequestData = try? await ValidatedSiopOpenId4VPRequest(authorizationRequestData: authorizationRequestData!)
    
    XCTAssertNotNil(validatedAuthorizationRequestData)
    
    do {
      let resolvedSiopOpenId4VPRequestData = try await ResolvedRequestData(clientMetaDataResolver: ClientMetaDataResolver(), presentationDefinitionResolver: PresentationDefinitionResolver(), validatedAuthorizationRequest: validatedAuthorizationRequestData!)
      
      XCTAssertNotNil(resolvedSiopOpenId4VPRequestData)
    } catch _ as FetchError {
      XCTAssert(true)
    } catch {
      
    }
  }
  
  func testValidationResolutionWithAuthorisationRequestGivenDataIsValid() async throws {
    
    let authorizationRequestData = AuthorisationRequestObject(from: TestsConstants.validVpTokenByClientByValuePresentationByReferenceUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    do {
      let authorizationRequest = try await AuthorizationRequest(
        authorizationRequestData: authorizationRequestData!
      )
      
      XCTAssertNotNil(authorizationRequest)
      
      switch authorizationRequest {
      case .notSecured(let resolved):
        switch resolved {
        case .vpToken:
          XCTAssert(true)
        default:
          XCTAssert(false, "Invalid resolution")
        }
      default:
        XCTAssert(false, "Invalid resolution")
      }
    } catch _ as FetchError {
      XCTAssert(true)
    } catch {
      
    }
  }
  
  // MARK: - Invalid data Testing
  
  func testAuthorisationValidationGivenDataIsInvalid() async throws {
    
    let authorizationRequestData = AuthorisationRequestObject(from: TestsConstants.invalidUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    do {
      _ = try await ValidatedSiopOpenId4VPRequest(authorizationRequestData: authorizationRequestData!)
    } catch let error as ValidatedAuthorizationError {
      switch error {
      case ValidatedAuthorizationError.unsupportedResponseType:
        XCTAssert(true)
      default:
        XCTAssert(false)
      }
      return
    } catch {
      XCTAssert(false)
    }
    
    XCTAssert(false)
  }
  
  func testSDKValidationResolutionGivenByValueDataIsValid() async throws {
    
    let sdk = SiopOpenID4VP()
    do {
      let presentationDefinition = try await sdk.process(url: TestsConstants.validVpTokenByClientByValuePresentationByReferenceUrl)
      
      XCTAssert(presentationDefinition.id == "32f54163-7166-48f1-93d8-ff217bdb0653")
      XCTAssert(presentationDefinition.inputDescriptors.count == 1)
    } catch _ as FetchError {
      XCTAssert(true)
    } catch {
      
    }
  }
  
  func testRequestObjectGivenValidJWT() async throws {
    
    let walletConfiguration = try preRegisteredWalletConfiguration()
    
    let authorizationRequestData = AuthorisationRequestObject(from: TestsConstants.validVpTokenByClientByValuePresentationByReferenceUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    let validatedAuthorizationRequestData = try? await ValidatedSiopOpenId4VPRequest(
      request: TestsConstants.passByValueJWT,
      walletConfiguration: walletConfiguration
    )
    
    XCTAssertNotNil(validatedAuthorizationRequestData)
    
    let resolvedSiopOpenId4VPRequestData = try? await ResolvedRequestData(
      clientMetaDataResolver: ClientMetaDataResolver(),
      presentationDefinitionResolver: PresentationDefinitionResolver(),
      validatedAuthorizationRequest: validatedAuthorizationRequestData!
    )
    
    XCTAssertNotNil(resolvedSiopOpenId4VPRequestData)
    
    switch resolvedSiopOpenId4VPRequestData! {
    case .vpToken:
      XCTAssert(true)
    default:
      XCTAssert(false)
    }
  }
  
  func testRequestObjectGivenValidJWTUri() async throws {
    
    let authorizationRequestData = AuthorisationRequestObject(from: TestsConstants.validVpTokenByClientByValuePresentationByReferenceUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    do {
      let validatedAuthorizationRequestData = try await ValidatedSiopOpenId4VPRequest(
        requestUri: TestsConstants.passByValueJWTURI,
        clientId: authorizationRequestData?.clientId
      )
      
      XCTAssertNotNil(validatedAuthorizationRequestData)
      
      let resolvedSiopOpenId4VPRequestData = try await ResolvedRequestData(
        clientMetaDataResolver: ClientMetaDataResolver(),
        presentationDefinitionResolver: PresentationDefinitionResolver(),
        validatedAuthorizationRequest: validatedAuthorizationRequestData
      )
      
      XCTAssertNotNil(resolvedSiopOpenId4VPRequestData)
      
      switch resolvedSiopOpenId4VPRequestData {
      case .vpToken, .idToken:
        XCTAssert(true)
      default:
        XCTAssert(false)
      }
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func testSDKValidationResolutionGivenDataRequestObjectByValueIsValid() async throws {
    
    let authorizationRequestData = AuthorisationRequestObject(from: TestsConstants.requestObjectUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    do {
      let validatedAuthorizationRequestData = try await ValidatedSiopOpenId4VPRequest(
        authorizationRequestData: authorizationRequestData!
      )
      
      XCTAssertNotNil(validatedAuthorizationRequestData)
      
      let resolvedSiopOpenId4VPRequestData = try await ResolvedRequestData(
        clientMetaDataResolver: ClientMetaDataResolver(),
        presentationDefinitionResolver: PresentationDefinitionResolver(),
        validatedAuthorizationRequest: validatedAuthorizationRequestData
      )
      
      XCTAssertNotNil(resolvedSiopOpenId4VPRequestData)
      
      switch resolvedSiopOpenId4VPRequestData {
      case .vpToken:
        XCTAssert(true)
      default:
        XCTAssert(false)
      }
    } catch _ as FetchError {
      XCTAssert(true)
    } catch {
      
    }
  }
  
  func testSDKValidationResolutionGivenDataRequestObjectByReferenceIsValid() async throws {
    
    let authorizationRequestData = AuthorisationRequestObject(from: TestsConstants.requestUriUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    do {
      let validatedAuthorizationRequestData = try await ValidatedSiopOpenId4VPRequest(
        authorizationRequestData: authorizationRequestData!
      )
      
      XCTAssertNotNil(validatedAuthorizationRequestData)
      
      let resolvedSiopOpenId4VPRequestData = try? await ResolvedRequestData(
        clientMetaDataResolver: ClientMetaDataResolver(),
        presentationDefinitionResolver: PresentationDefinitionResolver(),
        validatedAuthorizationRequest: validatedAuthorizationRequestData
      )
      
      XCTAssertNotNil(resolvedSiopOpenId4VPRequestData)
      
      switch resolvedSiopOpenId4VPRequestData! {
      case .vpToken, .idToken:
        XCTAssert(true)
      default:
        XCTAssert(false)
      }
    } catch _ as FetchError {
      XCTAssert(true)
    } catch {
      
    }
  }
  
  func testSDKValidationResolutionGivenDataRequestObjectByReferenceIsNotFoundURL() async throws {
    
    let authorizationRequestData = AuthorisationRequestObject(from: TestsConstants.requestExpiredUrl)
    
    XCTAssertNotNil(authorizationRequestData)
    
    do {
      _ = try await ValidatedSiopOpenId4VPRequest(
        authorizationRequestData: authorizationRequestData!
      )
    } catch let error as FetchError {
      print(error.localizedDescription)
      switch error {
      case .invalidStatusCode(_, let status):
        XCTAssert(status == 404)
        return
      default: break
      }
    } catch {
      XCTAssert(true)
      return
    }
    
    XCTAssert(false)
  }
  
  func testSDKInstanceValidationResolutionGivenDataRequestObjectByValueIsValid() async throws {
    
    let sdk = SiopOpenID4VP()
    
    do {
      let presentationDefinition = try await sdk.process(url: TestsConstants.requestObjectUrl)
      
      XCTAssertNotNil(presentationDefinition)
      
      XCTAssert(presentationDefinition.id == "32f54163-7166-48f1-93d8-ff217bdb0653")
      XCTAssert(presentationDefinition.inputDescriptors.count == 2)
      XCTAssert(presentationDefinition.inputDescriptors.first!.constraints.fields.first!.paths.first == "$.credentialSchema.id")
    } catch _ as FetchError {
      XCTAssert(true)
    } catch {
      
    }
  }
  
  func testSDKAuthorisationResolutionWithPublisherValidationResolutionGivenDataByReferenceIsValid() {
    
    let expectation = XCTestExpectation(description: "Authorisation request succesful")
    
    let sdk = SiopOpenID4VP()
    
    overrideDependencies()
    
    sdk.authorizationPublisher(for: TestsConstants.validByReferenceAuthorizeUrl)
      .sink { completion in
        expectation.fulfill()
      } receiveValue: { value in
        switch value {
        case .notSecured(let resolved):
          switch resolved {
          case .vpToken:
            XCTAssert(true)
          default:
            XCTAssert(false, "Invalid resolution")
          }
        default:
          XCTAssert(false, "Invalid resolution")
        }
      }.store(in: &subscriptions)
    
    wait(for: [expectation], timeout: 10.0)
  }
  
  func testSDKAuthorisationValidationGivenDataByReferenceIsValid() async throws {
    
    let sdk = SiopOpenID4VP()
    
    overrideDependencies()
    
    do {
      let result = try await sdk.authorize(url: TestsConstants.validByReferenceAuthorizeUrl)
      
      switch result {
      case .notSecured(let resolved):
        switch resolved {
        case .vpToken:
          XCTAssert(true)
        default:
          XCTAssert(false, "Invalid resolution")
        }
      default:
        XCTAssert(false, "Invalid resolution")
      }
    } catch {
      XCTAssert(true)
    }
  }
}

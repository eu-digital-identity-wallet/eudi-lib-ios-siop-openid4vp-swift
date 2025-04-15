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

public struct SiopOpenId4VPConfiguration {
  public let subjectSyntaxTypesSupported: [SubjectSyntaxType]
  public let preferredSubjectSyntaxType: SubjectSyntaxType
  public let decentralizedIdentifier: DecentralizedIdentifier
  public let idTokenTTL: TimeInterval
  public let presentationDefinitionUriSupported: Bool
  public let signingKey: SecKey
  public let signingKeySet: WebKeySet
  public let supportedClientIdSchemes: [SupportedClientIdScheme]
  public let vpFormatsSupported: [ClaimFormat]
  public let knownPresentationDefinitionsPerScope: [String: PresentationDefinition]
  public let jarConfiguration: JARConfiguration
  public let vpConfiguration: VPConfiguration
  public let errorDispatchPolicy: ErrorDispatchPolicy
  public let session: Networking
  
  public init(
    subjectSyntaxTypesSupported: [SubjectSyntaxType],
    preferredSubjectSyntaxType: SubjectSyntaxType,
    decentralizedIdentifier: DecentralizedIdentifier,
    idTokenTTL: TimeInterval = 600.0,
    presentationDefinitionUriSupported: Bool = false,
    signingKey: SecKey,
    signingKeySet: WebKeySet,
    supportedClientIdSchemes: [SupportedClientIdScheme],
    vpFormatsSupported: [ClaimFormat],
    knownPresentationDefinitionsPerScope: [String: PresentationDefinition] = [:],
    jarConfiguration: JARConfiguration = .noEncrytpionOption,
    vpConfiguration: VPConfiguration = VPConfiguration.default(),
    errorDispatchPolicy: ErrorDispatchPolicy = .onlyAuthenticatedClients,
    session: Networking = Self.walletSession
  ) {
    self.subjectSyntaxTypesSupported = subjectSyntaxTypesSupported
    self.preferredSubjectSyntaxType = preferredSubjectSyntaxType
    self.decentralizedIdentifier = decentralizedIdentifier
    self.idTokenTTL = idTokenTTL
    self.presentationDefinitionUriSupported = presentationDefinitionUriSupported
    self.signingKey = signingKey
    self.signingKeySet = signingKeySet
    self.supportedClientIdSchemes = supportedClientIdSchemes
    self.vpFormatsSupported = vpFormatsSupported
    self.knownPresentationDefinitionsPerScope = knownPresentationDefinitionsPerScope
    self.jarConfiguration = jarConfiguration
    self.vpConfiguration = vpConfiguration
    self.errorDispatchPolicy = errorDispatchPolicy
    self.session = session
  }
  
  internal init() throws {
    subjectSyntaxTypesSupported = []
    preferredSubjectSyntaxType = .decentralizedIdentifier
    decentralizedIdentifier = try DecentralizedIdentifier(rawValue: "did:example:123|did:example:456")
    idTokenTTL = 600.0
    presentationDefinitionUriSupported = false
    signingKey = try KeyController.generateRSAPrivateKey()
    signingKeySet = WebKeySet(keys: [])
    supportedClientIdSchemes = []
    vpFormatsSupported = []
    knownPresentationDefinitionsPerScope = [:]
    jarConfiguration = .noEncrytpionOption
    vpConfiguration = VPConfiguration.default()
    errorDispatchPolicy = .onlyAuthenticatedClients
    session = URLSession.shared
  }
  
  public static let walletSession: Networking = {
    /*let delegate = SelfSignedSessionDelegate()
     let configuration = URLSessionConfiguration.default
     return URLSession(
     configuration: configuration,
     delegate: delegate,
     delegateQueue: nil
     )*/
    URLSession.shared
  }()
}

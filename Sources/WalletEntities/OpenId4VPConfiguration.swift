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
@preconcurrency import Foundation

public struct OpenId4VPConfiguration: Sendable {
  public let subjectSyntaxTypesSupported: [SubjectSyntaxType]
  public let preferredSubjectSyntaxType: SubjectSyntaxType
  public let decentralizedIdentifier: DecentralizedIdentifier?
  public let idTokenTTL: TimeInterval
  public let presentationDefinitionUriSupported: Bool
  public let privateKey: SecKey
  public let publicWebKeySet: WebKeySet
  public let supportedClientIdSchemes: [SupportedClientIdPrefix]
  public let vpFormatsSupported: [ClaimFormat]
  public let jarConfiguration: JARConfiguration
  public let vpConfiguration: VPConfiguration
  public let errorDispatchPolicy: ErrorDispatchPolicy
  public let session: Networking
  public let responseEncryptionConfiguration: ResponseEncryptionConfiguration
  
  public init(
    subjectSyntaxTypesSupported: [SubjectSyntaxType] = [.decentralizedIdentifier, .jwkThumbprint],
    preferredSubjectSyntaxType: SubjectSyntaxType = .jwkThumbprint,
    decentralizedIdentifier: DecentralizedIdentifier? = nil,
    idTokenTTL: TimeInterval = 600.0,
    presentationDefinitionUriSupported: Bool = false,
    privateKey: SecKey,
    publicWebKeySet: WebKeySet,
    supportedClientIdSchemes: [SupportedClientIdPrefix],
    vpFormatsSupported: [ClaimFormat] = ClaimFormat.default(),
    jarConfiguration: JARConfiguration = .noEncryptionOption,
    vpConfiguration: VPConfiguration = .default(),
    errorDispatchPolicy: ErrorDispatchPolicy = .onlyAuthenticatedClients,
    session: Networking = Self.walletSession,
    responseEncryptionConfiguration: ResponseEncryptionConfiguration
  ) {
    self.subjectSyntaxTypesSupported = subjectSyntaxTypesSupported
    self.preferredSubjectSyntaxType = preferredSubjectSyntaxType
    self.decentralizedIdentifier = decentralizedIdentifier
    self.idTokenTTL = idTokenTTL
    self.presentationDefinitionUriSupported = presentationDefinitionUriSupported
    self.privateKey = privateKey
    self.publicWebKeySet = publicWebKeySet
    self.supportedClientIdSchemes = supportedClientIdSchemes
    self.vpFormatsSupported = vpFormatsSupported
    self.jarConfiguration = jarConfiguration
    self.vpConfiguration = vpConfiguration
    self.errorDispatchPolicy = errorDispatchPolicy
    self.session = session
    self.responseEncryptionConfiguration = responseEncryptionConfiguration
  }

  internal init() throws {
    subjectSyntaxTypesSupported = []
    preferredSubjectSyntaxType = .decentralizedIdentifier
    decentralizedIdentifier = try DecentralizedIdentifier(rawValue: "did:example:123|did:example:456")
    idTokenTTL = 600.0
    presentationDefinitionUriSupported = false
    privateKey = try KeyController.generateRSAPrivateKey()
    publicWebKeySet = WebKeySet(keys: [])
    supportedClientIdSchemes = []
    vpFormatsSupported = []
    jarConfiguration = .noEncryptionOption
    vpConfiguration = .default()
    errorDispatchPolicy = .onlyAuthenticatedClients
    session = URLSession.shared
    responseEncryptionConfiguration = .unsupported
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

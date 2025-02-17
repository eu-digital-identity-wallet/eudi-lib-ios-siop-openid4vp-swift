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

public struct SupportedTransactionDataType: Codable {
  public let type: TransactionDataType
  public let hashAlgorithms: Set<HashAlgorithm>
  
  public init(type: TransactionDataType, hashAlgorithms: Set<HashAlgorithm>) throws {
    guard !hashAlgorithms.isEmpty else {
      throw NSError(domain: "SupportedTransactionDataTypeError", code: 1, userInfo: [NSLocalizedDescriptionKey: "hashAlgorithms cannot be empty"])
    }
    guard hashAlgorithms.contains(HashAlgorithm.sha256) else {
      throw NSError(domain: "SupportedTransactionDataTypeError", code: 2, userInfo: [NSLocalizedDescriptionKey: "'sha-256' must be a supported hash algorithm"])
    }
    self.type = type
    self.hashAlgorithms = hashAlgorithms
  }
  
  public static func `default`() -> SupportedTransactionDataType {
    try! .init(
      type: .init(value: "transaction_data"),
      hashAlgorithms: .init([.sha256])
    )
  }
}

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
  public let session: Networking
  public let supportedTransactionData: SupportedTransactionDataType
  
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
    jarConfiguration: JARConfiguration = .default,
    vpConfiguration: VPConfiguration = VPConfiguration.default(),
    session: Networking = Self.walletSession,
    supportedTransactionData: SupportedTransactionDataType = SupportedTransactionDataType.default()
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
    self.session = session
    self.supportedTransactionData = supportedTransactionData
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
    jarConfiguration = .default
    vpConfiguration = VPConfiguration.default()
    session = URLSession.shared
    supportedTransactionData = SupportedTransactionDataType.default()
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

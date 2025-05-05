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
@preconcurrency import SwiftyJSON

public typealias Credentials = [CredentialQuery]
public typealias CredentialSets = [CredentialSetQuery]
public typealias CredentialSet = Set<QueryId>
public typealias ClaimSet = Set<ClaimId>

public enum DCQLError: Error {
  case emptyCredentials
  case duplicateQueryId
  case unknownQueryId
  case emptyCredentialSet
  case emptyNamespace
  case emptyClaimName
  case emptyDocType
}

public struct CredentialQuery: Codable, Equatable, Sendable {
  enum CodingKeys: String, CodingKey {
    case id
    case format
    case meta
    case claims
    case claimSets = "claim_sets"
  }
  
  public let id: QueryId
  public let format: Format
  public let meta: JSON?
  public let claims: [ClaimsQuery]?
  public let claimSets: [ClaimSet]?
  
  public init(
    id: QueryId,
    format: Format,
    meta: JSON? = nil,
    claims: [ClaimsQuery]? = nil,
    claimSets: [ClaimSet]? = nil
  ) {
    self.id = id
    self.format = format
    self.meta = meta
    self.claims = claims
    self.claimSets = claimSets
  }
  
  public static func sdJwtVc(
    id: QueryId,
    sdJwtVcMeta: DCQLMetaSdJwtVcExtensions? = nil,
    claims: [ClaimsQuery]? = nil,
    claimSets: [ClaimSet]? = nil
  ) throws -> CredentialQuery {
    var json: JSON?
    if let jsonData = try? JSONEncoder().encode(sdJwtVcMeta) {
      json = JSON(jsonData)
    }
    return CredentialQuery(
      id: id,
      format: try Format.SdJwtVc(),
      meta: json,
      claims: claims,
      claimSets: claimSets
    )
  }
  
  public static func mdoc(
    id: QueryId,
    msoMdocMeta: DCQLMetaMsoMdocExtensions? = nil,
    claims: [ClaimsQuery]? = nil,
    claimSets: [ClaimSet]? = nil
  ) throws -> CredentialQuery {
    
    var json: JSON?
    if let jsonData = try? JSONEncoder().encode(msoMdocMeta) {
      json = JSON(jsonData)
    }
    
    return CredentialQuery(
      id: id,
      format: try Format.MsoMdoc(),
      meta: json,
      claims: claims,
      claimSets: claimSets
    )
  }
}

public struct CredentialSetQuery: Codable, Equatable, Sendable {
  
  public static let defaultRequiredValue: Bool? = true
  
  public let options: [CredentialSet]
  public let required: Bool?
  public let purpose: JSON?
  
  enum CodingKeys: String, CodingKey {
    case options, required, purpose
  }
  
  public init(
    options: [CredentialSet],
    required: Bool? = CredentialSetQuery.defaultRequiredValue,
    purpose: JSON? = nil
  ) throws {
    for credentialSet in options {
      guard !credentialSet.isEmpty else { throw DCQLError.emptyCredentialSet }
    }
    self.options = options
    self.required = required
    self.purpose = purpose
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.options = try container.decode([CredentialSet].self, forKey: .options)
    self.required = try container.decodeIfPresent(Bool.self, forKey: .required) ?? Self.defaultRequiredValue
    self.purpose = try container.decodeIfPresent(JSON.self, forKey: .purpose)
  }
}

public struct ClaimId: Codable, Hashable, Sendable {
  public let id: String
  
  enum CodingKeys: String, CodingKey {
    case id
  }
  
  public init(_ id: String) throws {
    try ClaimId.ensureValid(id)
    self.id = id
  }
  
  public static func ensureValid(_ value: String) throws {
    try DCQLId.ensureValid(value)
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let id = try container.decode(String.self)
    try ClaimId.ensureValid(id)
    try self.init(id)
  }
}

internal struct DCQLId {
  
  @discardableResult
  static func ensureValid(_ value: String) throws -> String {
    guard !value.isEmpty else {
      throw ValidationError.emptyValue
    }
    
    let regex = "^[a-zA-Z0-9_-]+$" // Alphanumeric, underscore, hyphen
    let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
    
    guard predicate.evaluate(with: value) else {
      throw ValidationError.invalidFormat
    }
    
    return value
  }
}

public struct DCQL: Codable, Equatable, Sendable {
  
  public let credentials: Credentials
  public let credentialSets: CredentialSets?
  
  enum CodingKeys: String, CodingKey {
    case credentials
    case credentialSets = "credential_sets"
  }
  
  public init(
    credentials: Credentials,
    credentialSets: CredentialSets? = nil
  ) throws {
    let uniqueIds = try credentials.ensureValid()
    if let credentialSets = credentialSets {
      try credentialSets.ensureValid(knownIds: uniqueIds)
    }
    self.credentials = credentials
    self.credentialSets = credentialSets
  }
  
  init(from json: JSON) throws {
    
    let credentialsData = try json[OpenId4VPSpec.DCQL_CREDENTIALS].rawData()
    let credentials = try JSONDecoder().decode(Credentials.self, from: credentialsData)
    
    var credentialSets: CredentialSets? = nil
    if json[OpenId4VPSpec.DCQL_CREDENTIAL_SETS].exists() {
      let credentialSetsData = try json[OpenId4VPSpec.DCQL_CREDENTIAL_SETS].rawData()
      credentialSets = try JSONDecoder().decode(CredentialSets.self, from: credentialSetsData)
    }
    
    try self.init(credentials: credentials, credentialSets: credentialSets)
  }
}

public extension Credentials {
  func ensureValid() throws -> CredentialSet {
    guard !isEmpty else { throw DCQLError.emptyCredentials }
    return try ensureUniqueIds()
  }
  
  func ensureUniqueIds() throws -> CredentialSet {
    let uniqueIds = Set(map { $0.id })
    guard uniqueIds.count == count else { throw DCQLError.duplicateQueryId }
    return uniqueIds
  }
}

public extension CredentialSets {
  func ensureValid(knownIds: CredentialSet) throws {
    guard !isEmpty else { throw DCQLError.emptyCredentials }
    for credentialSet in self {
      try credentialSet.ensureOptionsWithKnownIds(knownIds: knownIds)
    }
  }
}

public extension CredentialSetQuery {
  func ensureOptionsWithKnownIds(knownIds: CredentialSet) throws {
    for credentialSet in options {
      guard credentialSet.allSatisfy({ knownIds.contains($0) }) else {
        throw DCQLError.unknownQueryId
      }
    }
  }
}

public struct ClaimsQuery: Codable, Equatable, Sendable {
  public let id: ClaimId?
  public let path: ClaimPath?
  public let values: [String]?
  public let namespace: MsoMdocNamespace?
  public let claimName: MsoMdocClaimName?
  
  enum CodingKeys: String, CodingKey {
    case id
    case path
    case values
    case namespace = "namespace"
    case claimName = "claim_name"
  }
  
  public init(
    id: ClaimId?,
    path: ClaimPath?,
    values: [String]?,
    namespace: MsoMdocNamespace?,
    claimName: MsoMdocClaimName?
  ) {
    self.id = id
    self.path = path
    self.values = values
    self.namespace = namespace
    self.claimName = claimName
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.id = try container.decodeIfPresent(ClaimId.self, forKey: .id)
    self.path = try container.decodeIfPresent(ClaimPath.self, forKey: .path)
    self.values = try container.decodeIfPresent([String].self, forKey: .values)
    self.namespace = try container.decodeIfPresent(MsoMdocNamespace.self, forKey: .namespace)
    self.claimName = try container.decodeIfPresent(MsoMdocClaimName.self, forKey: .claimName)
    
    if namespace == nil && claimName != nil {
      throw DecodingError.dataCorruptedError(
        forKey: .path,
        in: container,
        debugDescription: "Namespace must be present when claim name is present"
      )
    }
    
    if namespace != nil && claimName == nil {
      throw DecodingError.dataCorruptedError(
        forKey: .path,
        in: container,
        debugDescription: "Claim name must be present when namespace is present"
      )
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encodeIfPresent(id, forKey: .id)
    try container.encodeIfPresent(values, forKey: .values)
    
    // Enforce consistency: either both namespace and claimName must be present or both absent
    switch (namespace, claimName) {
    case (.some(let ns), .some(let name)):
      try container.encode(ns, forKey: .namespace)
      try container.encode(name, forKey: .claimName)
    case (nil, nil):
      // Nothing to encode here
      break
    default:
      throw EncodingError.invalidValue(
        self,
        EncodingError.Context(
          codingPath: container.codingPath,
          debugDescription: "Namespace and claim name must either both be present or both be nil."
        )
      )
    }
  }
  
  public static func sdJwtVc(
    id: ClaimId? = nil,
    path: ClaimPath,
    values: [String]? = nil
  ) -> ClaimsQuery {
    ClaimsQuery(
      id: id,
      path: path,
      values: values,
      namespace: nil,
      claimName: nil
    )
  }
  
  public static func mdoc(
    id: ClaimId? = nil,
    values: [String]? = nil,
    namespace: MsoMdocNamespace,
    claimName: MsoMdocClaimName
  ) -> ClaimsQuery {
    ClaimsQuery(
      id: id,
      path: nil,
      values: values,
      namespace: namespace,
      claimName: claimName
    )
  }
}

public struct MsoMdocNamespace: Codable, CustomStringConvertible, Equatable, Sendable {
  public let namespace: String
  
  public init(_ namespace: String) throws {
    guard !namespace.isEmpty else {
      throw DCQLError.emptyNamespace
    }
    self.namespace = namespace
  }
  
  enum CodingKeys: String, CodingKey {
    case namespace = "namespace"
  }
  
  public var description: String {
    return namespace
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let namespace = try container.decode(String.self)
    
    if namespace.isEmpty {
      throw DCQLError.emptyNamespace
    }
    
    self.namespace = namespace
  }
}

public struct MsoMdocClaimName: Codable, CustomStringConvertible, Equatable, Sendable {
  
  public let claimName: String
  
  public init(claimName: String) throws {
    guard !claimName.isEmpty else {
      throw DCQLError.emptyClaimName
    }
    self.claimName = claimName
  }
  
  public var description: String {
    return claimName
  }
  
  enum CodingKeys: String, CodingKey {
    case claimName = "claim_name"
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let decodedValue = try container.decode(String.self)
    
    guard !decodedValue.isEmpty else {
      throw DCQLError.emptyClaimName
    }
    
    self.claimName = decodedValue
  }
}

// MARK: - Extensions

public struct DCQLMetaSdJwtVcExtensions: Codable {
  
  public let vctValues: [String]?
  
  enum CodingKeys: String, CodingKey {
    case vctValues = "vct_values"
  }
}

public struct DCQLMetaMsoMdocExtensions: Encodable {
  
  public let doctypeValue: MsoMdocDocType?
  
  enum CodingKeys: String, CodingKey {
    case doctypeValue = "doctype_value"
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    if let doctypeValue = doctypeValue {
      try container.encode(doctypeValue.value, forKey: .doctypeValue)
    }
  }
}

public struct MsoMdocDocType: CustomStringConvertible {
  public let value: String
  
  public init(value: String) throws {
    guard !value.isEmpty else {
      throw DCQLError.emptyDocType
    }
    self.value = value
  }
  
  public var description: String {
    return value
  }
}

public struct MsoMdocClaimsQueryExtension: Decodable {
  
  public let namespace: MsoMdocNamespace?
  public let claimName: MsoMdocClaimName?
  
  enum CodingKeys: String, CodingKey {
    case namespace
    case claimName = "claim_name"
  }
}

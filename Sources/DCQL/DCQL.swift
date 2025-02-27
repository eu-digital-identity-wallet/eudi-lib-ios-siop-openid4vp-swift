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
import SwiftyJSON

public typealias Credentials = [CredentialQuery]
public typealias CredentialSets = [CredentialSetQuery]
public typealias CredentialSet = Set<QueryId>
public typealias ClaimSet = Set<ClaimId>

public struct CredentialQuery: Decodable {
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case format = "format"
    case meta = "meta"
    case claims = "claims"
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
}

public struct CredentialSetQuery: Codable {
  enum CodingKeys: String, CodingKey {
    case options = "options"
    case required = "required"
    case purpose = "purpose"
  }
  
  public let options: [CredentialSet]
  public let required: Bool?
  public let purpose: JSON?
  
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
  
  public static let defaultRequiredValue: Bool? = true
}

public struct ClaimId: Codable, Hashable {
  public let value: String
  
  public init(_ value: String) throws {
    try ClaimId.ensureValid(value)
    self.value = value
  }
  
  public static func ensureValid(_ value: String) throws {
    try DCQLId.ensureValid(value)
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let value = try container.decode(String.self)
    try ClaimId.ensureValid(value)
    try self.init(value)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value)
  }
}

public enum DCQLError: Error {
  case emptyCredentials
  case duplicateQueryId
  case unknownQueryId
  case emptyCredentialSet
}


public struct DCQLId {
  
  @discardableResult
  public static func ensureValid(_ value: String) throws -> String {
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

public struct DCQL: Decodable {
  enum CodingKeys: String, CodingKey {
    case credentials = "credentials"
    case credentialSets = "credential_sets"
  }
  
  public let credentials: Credentials
  public let credentialSets: CredentialSets?
  
  public init(credentials: Credentials, credentialSets: CredentialSets? = nil) throws {
    let uniqueIds = try credentials.ensureValid()
    if let credentialSets = credentialSets {
      try credentialSets.ensureValid(knownIds: uniqueIds)
    }
    self.credentials = credentials
    self.credentialSets = credentialSets
  }
  
  init(from json: JSON) throws {
    
    let credentialsData = try json["credentials"].rawData()
    let credentials = try JSONDecoder().decode(Credentials.self, from: credentialsData)
    
    // Decode 'credential_sets' if it exists
    var credentialSets: CredentialSets? = nil
    if json["credential_sets"].exists() {
      let credentialSetsData = try json["credential_sets"].rawData()
      credentialSets = try JSONDecoder().decode(CredentialSets.self, from: credentialSetsData)
    }
    
    // Initialize DCQL
    try self.init(credentials: credentials, credentialSets: credentialSets)
  }
}

public extension Credentials {
  func ensureValid() throws -> Set<QueryId> {
    guard !isEmpty else { throw DCQLError.emptyCredentials }
    return try ensureUniqueIds()
  }
  
  func ensureUniqueIds() throws -> Set<QueryId> {
    let uniqueIds = Set(map { $0.id })
    guard uniqueIds.count == count else { throw DCQLError.duplicateQueryId }
    return uniqueIds
  }
}

public extension CredentialSets {
  func ensureValid(knownIds: Set<QueryId>) throws {
    guard !isEmpty else { throw DCQLError.emptyCredentials }
    for credentialSet in self {
      try credentialSet.ensureOptionsWithKnownIds(knownIds: knownIds)
    }
  }
}

public extension CredentialSetQuery {
  func ensureOptionsWithKnownIds(knownIds: Set<QueryId>) throws {
    for credentialSet in options {
      guard credentialSet.allSatisfy({ knownIds.contains($0) }) else {
        throw DCQLError.unknownQueryId
      }
    }
  }
}

public struct ClaimsQuery: Decodable {
  public let id: ClaimId?
  public let path: ClaimPath?
  public let values: [String]?
  public let namespace: MsoMdocNamespace?
  public let claimName: MsoMdocClaimName?
  
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case path = "path"
    case values = "values"
    case namespace = "namespace"
    case claimName = "claim_name"
  }
  
  // Companion methods equivalent in Swift
  public static func sdJwtVc(id: ClaimId? = nil, path: ClaimPath, values: [String]? = nil) -> ClaimsQuery {
    return ClaimsQuery(id: id, path: path, values: values, namespace: nil, claimName: nil)
  }
  
  public static func mdoc(id: ClaimId? = nil, values: [String]? = nil, namespace: MsoMdocNamespace, claimName: MsoMdocClaimName) -> ClaimsQuery {
    return ClaimsQuery(id: id, path: nil, values: values, namespace: namespace, claimName: claimName)
  }
  
  public static func ensureMsoMdocExtensions(claimsQuery: ClaimsQuery) {
    // Placeholder for ensuring the mdoc extensions; no precondition checks
    // Just an example of how you could access the properties.
    let _ = claimsQuery.namespace
    let _ = claimsQuery.claimName
  }
}


public struct DCQLMetaSdJwtVcExtensions: Codable {
  
  public let vctValues: [String]?
  
  enum CodingKeys: String, CodingKey {
    case vctValues = "vct_values"
  }
}


public enum MsoMdocError: Error {
  case emptyNamespace
  case emptyClaimName
  case emptyDocType
}

public struct DCQLMetaMsoMdocExtensions: Codable {
  /**
   * Specifies an allowed value for the doctype of the requested Verifiable Credential.
   * It MUST be a valid doctype identifier as defined.
   */
  public let doctypeValue: MsoMdocDocType?
  
  enum CodingKeys: String, CodingKey {
    case doctypeValue = "doctype_value"
  }
}

public struct MsoMdocDocType: Codable, CustomStringConvertible {
  public let value: String
  
  // Throwing initializer that checks if the value is not empty
  public init(value: String) throws {
    guard !value.isEmpty else {
      throw MsoMdocError.emptyDocType
    }
    self.value = value
  }
  
  public var description: String {
    return value
  }
  
  // Codable conformance
  enum CodingKeys: String, CodingKey {
    case value
  }
  
  // Encode the value for JSON
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value)
  }
  
  // Decode the value from JSON
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let decodedValue = try container.decode(String.self)
    
    guard !decodedValue.isEmpty else {
      throw MsoMdocError.emptyDocType
    }
    
    self.value = decodedValue
  }
}

public struct MsoMdocClaimsQueryExtension: Decodable {
  // Namespace of the data element within the mdoc (Optional)
  public let namespace: MsoMdocNamespace?
  
  // Data element identifier within the provided namespace (Optional)
  public let claimName: MsoMdocClaimName?
  
  // Coding keys to map JSON keys to the struct properties
  enum CodingKeys: String, CodingKey {
    case namespace = "namespace"
    case claimName = "claim_name"
  }
}

public struct MsoMdocNamespace: Decodable, CustomStringConvertible {
  public let namespace: String
  
  public init(_ namespace: String) throws {
    guard !namespace.isEmpty else {
      throw MsoMdocError.emptyNamespace
    }
    self.namespace = namespace
  }
  
  public var description: String {
    return namespace
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let namespace = try container.decode(String.self)
    
    // Validate the namespace during decoding
    if namespace.isEmpty {
      throw MsoMdocError.emptyNamespace
    }
    
    self.namespace = namespace
  }
}

public struct MsoMdocClaimName: Codable, CustomStringConvertible {
  public let value: String
  
  // Initializer that throws an error if the value is empty
  public init(value: String) throws {
    guard !value.isEmpty else {
      throw MsoMdocError.emptyClaimName
    }
    self.value = value
  }
  
  public var description: String {
    return value
  }
  
  // Codable conformance to handle encoding/decoding
  enum CodingKeys: String, CodingKey {
    case value
  }
  
  // Encode the value for JSON
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value)
  }
  
  // Decode the value from JSON
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let decodedValue = try container.decode(String.self)
    
    guard !decodedValue.isEmpty else {
      throw MsoMdocError.emptyClaimName
    }
    
    self.value = decodedValue
  }
}



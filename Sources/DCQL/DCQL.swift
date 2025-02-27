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

public struct CredentialQuery: Codable {
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case format = "format"
    case meta = "meta"
  }
  
  public let id: QueryId
  public let format: Format
  public let meta: JSON?
  
  public init(id: QueryId, format: Format, meta: JSON? = nil) {
    self.id = id
    self.format = format
    self.meta = meta
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
  
  public init(_ value: String) {
    ClaimId.ensureValid(value)
    self.value = value
  }
  
  public static func ensureValid(_ value: String) {
    // Add validation logic similar to DCQLId.ensureValid(value)
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let value = try container.decode(String.self)
    ClaimId.ensureValid(value)
    self.init(value)
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

public struct DCQL: Codable {
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

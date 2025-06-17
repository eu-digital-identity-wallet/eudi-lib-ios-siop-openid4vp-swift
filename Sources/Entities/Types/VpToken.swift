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

public typealias Base64URL = String

public enum VerifiablePresentation: Encodable, Sendable {
  case generic(String)
  case json(JSON)
}

extension VerifiablePresentation {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    switch self {
    case .generic(let value):
      try container.encode(value)

    case .json(let value):
      try container.encode(value)
    }
  }
}

// Custom error types for encoding
public enum VpTokenError: Error {
  case notExpected
  case notSupported
}

public struct VpToken: Encodable {

  public let verifiablePresentations: [VerifiablePresentation]

  public init(
    verifiablePresentations: [VerifiablePresentation]
  ) {
    self.verifiablePresentations = verifiablePresentations
  }

  // Helper function to encode individual VerifiablePresentation cases
  private func encodeToken(_ token: VerifiablePresentation) throws -> JSON {
    switch token {
    case .generic(let value):
      return JSON(value)
    case .json(let json):
      return json
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    // Handle the case when there are no verifiable presentations
    guard !verifiablePresentations.isEmpty else {
      throw VpTokenError.notExpected
    }

    // Handle the case when there is a single verifiable presentation
    if verifiablePresentations.count == 1 {

      guard let token = verifiablePresentations.first else {
        throw VpTokenError.notExpected
      }

      switch token {
      case .generic(let value):
        try container.encode(value)
      case .json(let json):
        try container.encode(json)
      }
    } else {

      // Handle the case when there are multiple verifiable presentations
      let jsonArray = try verifiablePresentations.map { try encodeToken($0) }
      try container.encode(jsonArray)
    }
  }
}

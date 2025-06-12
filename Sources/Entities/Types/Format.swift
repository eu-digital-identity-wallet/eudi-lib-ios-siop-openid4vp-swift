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

// Define a custom error type
public enum FormatError: Error, LocalizedError {
  case blankValue

  public var errorDescription: String? {
    switch self {
    case .blankValue:
      return "Format cannot be blank"
    }
  }
}

public struct Format: Hashable, Codable, Sendable {

  public let format: String

  enum CodingKeys: String, CodingKey {
    case format = "format"
  }

  // Initializer to ensure the value is valid
  public init(format: String) throws {
    guard !format.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      throw FormatError.blankValue
    }
    self.format = format
  }

  public var description: String {
    return format
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let format = try container.decode(String.self)
    try self.init(format: format) // Ensure validation on decoding
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(format)
  }

  public static func MsoMdoc() throws -> Format {
    return try Format(format: OpenId4VPSpec.FORMAT_MSO_MDOC)
  }

  public static func SdJwtVc() throws -> Format {
    return try Format(format: OpenId4VPSpec.FORMAT_SD_JWT_VC)
  }

  public static func W3CJwtVcJson() throws -> Format {
    return try Format(format: OpenId4VPSpec.FORMAT_W3C_SIGNED_JWT)
  }
}

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

public struct VpFormatsTO: Codable, Equatable, Sendable {
  public let vcSdJwt: VcSdJwtTO?
  public let jwtVp: JwtVpTO?
  public let ldpVp: LdpVpTO?
  public let msoMdoc: MsoMdocTO?

  public init(
    vcSdJwt: VcSdJwtTO? = nil,
    jwtVp: JwtVpTO? = nil,
    ldpVp: LdpVpTO? = nil,
    msoMdoc: MsoMdocTO? = nil
  ) {
    self.vcSdJwt = vcSdJwt
    self.jwtVp = jwtVp
    self.ldpVp = ldpVp
    self.msoMdoc = msoMdoc
  }

  enum CodingKeys: String, CodingKey {
    case vcSdJwt = "dc+sd-jwt"
    case jwtVp = "jwt_vp"
    case ldpVp = "ldp_vp"
    case msoMdoc = "mso_mdoc"
  }
}

public struct VcSdJwtTO: Codable, Equatable, Sendable {
  public let sdJwtAlgorithms: [String]?
  public let kdJwtAlgorithms: [String]?

  enum CodingKeys: String, CodingKey {
    case sdJwtAlgorithms = "sd-jwt_alg_values"
    case kdJwtAlgorithms = "kb-jwt_alg_values"
  }

  public init(
    sdJwtAlgorithms: [String]?,
    kdJwtAlgorithms: [String]?
  ) {
    self.sdJwtAlgorithms = sdJwtAlgorithms
    self.kdJwtAlgorithms = kdJwtAlgorithms
  }
}

public struct MsoMdocTO: Codable, Equatable, Sendable {
  public let algorithms: [String]?

  enum CodingKeys: String, CodingKey {
    case algorithms = "alg"
  }

  public init(
    algorithms: [String]?
  ) {
    self.algorithms = algorithms
  }
}

public struct JwtVpTO: Codable, Equatable, Sendable {
  public let alg: [String]

  public init(alg: [String]) {
    self.alg = alg
  }
}

public struct LdpVpTO: Codable, Equatable, Sendable {
  public let proofType: [String]

  enum CodingKeys: String, CodingKey {
    case proofType = "proof_type"
  }

  public init(proofType: [String]) {
    self.proofType = proofType
  }
}

public enum VpFormat: Equatable, Sendable {

  case sdJwtVc(
    sdJwtAlgorithms: [JWSAlgorithm],
    kbJwtAlgorithms: [JWSAlgorithm]
  )
  case msoMdoc(
    algorithms: [JWSAlgorithm]
  )
  case jwtVp(algorithms: [String])
  case ldpVp(proofTypes: [String])

  public static func createSdJwtVc(
    sdJwtAlgorithms: [JWSAlgorithm],
    kbJwtAlgorithms: [JWSAlgorithm]
  ) throws -> VpFormat {

    guard !sdJwtAlgorithms.isEmpty else {
      throw ValidationError.validationError("SD-JWT algorithms cannot be empty")
    }

    return .sdJwtVc(
      sdJwtAlgorithms: sdJwtAlgorithms,
      kbJwtAlgorithms: kbJwtAlgorithms
    )
  }

  public static func createMsoMdoc(
    algorithms: [JWSAlgorithm]
  ) throws -> VpFormat {

    guard !algorithms.isEmpty else {
      throw ValidationError.validationError("MSO MDOC algorithms cannot be empty")
    }

    return .msoMdoc(
      algorithms: algorithms
    )
  }
}

public extension VpFormat {
  func formatName() -> FormatName {
    switch self {
    case .msoMdoc:
      return .MSO_MDOC
    case .sdJwtVc:
      return .SD_JWT_VC
    case .jwtVp:
      return .JWT_VP
    case .ldpVp:
      return .LDP_VP
    }
  }

  enum FormatName: String {
    case MSO_MDOC
    case SD_JWT_VC
    case JWT_VP
    case LDP_VP
  }
}

public struct VpFormats: Equatable, Sendable {

  static let vpFormats = "vp_formats"
  public let values: [VpFormat]

  public static func `default`() throws -> VpFormats {
    try VpFormats(values: [
      .sdJwtVc(
        sdJwtAlgorithms: [JWSAlgorithm(.ES256)],
        kbJwtAlgorithms: [JWSAlgorithm(.ES256)]
      ),
      .msoMdoc(
        algorithms: [JWSAlgorithm(.ES256)]
      )
    ])
  }

  public static func empty() throws -> VpFormats {
    try VpFormats(values: [])
  }

  public init?(jsonString: String?) throws {
    guard let jsonString = jsonString else {
      return nil
    }
    let json = JSON(parseJSON: jsonString)
    try? self.init(json: json)
  }

  public init?(json: JSON) throws {
    guard let dictionaryObject = json.dictionaryObject else {
      return nil
    }

    let vpFormatsDictionary: JSON = JSON(dictionaryObject)[Self.vpFormats]
    if let formats = try? vpFormatsDictionary.decoded(as: VpFormatsTO.self) {
      try? self.init(from: formats)
    } else {
      return nil
    }
  }

  public init(formats: VpFormat...) throws {
    self.values = formats
    try VpFormats.ensureUniquePerFormat(formats: formats)
  }

  public init(values: [VpFormat]) throws {
    self.values = values
    try VpFormats.ensureUniquePerFormat(formats: values)
  }

  func contains(_ format: VpFormat) -> Bool {
    return values.contains(where: { $0 == format })
  }

  public static func common(_ this: VpFormats, _ that: VpFormats) -> VpFormats? {
    var commonFormats: [VpFormat] = []

    for format in this.values {
      if that.contains(format) {
        commonFormats.append(format)
      }
    }

    return commonFormats.isEmpty ?
    nil :
    try? VpFormats(values: commonFormats)
  }

  private static func ensureUniquePerFormat(formats: [VpFormat]) throws {
    let groupedFormats = Dictionary(grouping: formats) { $0.formatName() }

    for (formatName, instances) in groupedFormats {
      guard instances.count == 1 else {
        throw ValidationError.validationError(
          "Multiple instances \(instances.count) found for \(formatName)."
        )
      }
    }
  }
}

public extension VpFormats {

  // New initializer that accepts a VpFormatsTO object
  init?(from to: VpFormatsTO?) throws {

    guard let to = to else {
      return nil
    }

    var formats: [VpFormat] = []

    if let vcSdJwt = to.vcSdJwt {
      let sdJwtAlgorithms = vcSdJwt.sdJwtAlgorithms?.compactMap { JWSAlgorithm(name: $0) } ?? []
      let kbJwtAlgorithms = vcSdJwt.kdJwtAlgorithms?.compactMap { JWSAlgorithm(name: $0) } ?? []

      let sdJwtVcFormat = VpFormat.sdJwtVc(
        sdJwtAlgorithms: sdJwtAlgorithms,
        kbJwtAlgorithms: kbJwtAlgorithms
      )
      formats.append(sdJwtVcFormat)
    }

    if let msoMdoc = to.msoMdoc {
      let algorithms = msoMdoc.algorithms?.compactMap { JWSAlgorithm(name: $0) } ?? []
      let msoMdocFormat = VpFormat.msoMdoc(
        algorithms: algorithms
      )
      formats.append(msoMdocFormat)
    }

    if let jwtVp = to.jwtVp {
      let jwtVpFormat = VpFormat.jwtVp(algorithms: jwtVp.alg)
      formats.append(jwtVpFormat)
    }

    if let ldpVp = to.ldpVp {
      let ldpVpFormat = VpFormat.ldpVp(proofTypes: ldpVp.proofType)
      formats.append(ldpVpFormat)
    }

    try self.init(values: formats)
  }

  // New initializer that accepts an array of VpFormatsTO objects
  init?(from tos: [VpFormatsTO]?) throws {

    guard let tos = tos else {
      return nil
    }

    var formats: [VpFormat] = []

    for to in tos {
      // Convert VcSdJwtTO if it exists
      if let vcSdJwt = to.vcSdJwt {
        let sdJwtAlgorithms = vcSdJwt.sdJwtAlgorithms?.compactMap { JWSAlgorithm(name: $0) } ?? []
        let kbJwtAlgorithms = vcSdJwt.kdJwtAlgorithms?.compactMap { JWSAlgorithm(name: $0) } ?? []

        let sdJwtVcFormat = VpFormat.sdJwtVc(
          sdJwtAlgorithms: sdJwtAlgorithms,
          kbJwtAlgorithms: kbJwtAlgorithms
        )
        formats.append(sdJwtVcFormat)
      }

      // Add msoMdoc if it exists
      if let msoMdoc = to.msoMdoc {
        let algorithms = msoMdoc.algorithms?.compactMap { JWSAlgorithm(name: $0) } ?? []
        let msoMdocFormat = VpFormat.msoMdoc(
          algorithms: algorithms
        )
        formats.append(msoMdocFormat)
      }

      // Convert JwtVpTO if it exists
      if let jwtVp = to.jwtVp {
        let jwtVpFormat = VpFormat.jwtVp(algorithms: jwtVp.alg)
        formats.append(jwtVpFormat)
      }

      // Convert LdpVpTO if it exists
      if let ldpVp = to.ldpVp {
        let ldpVpFormat = VpFormat.ldpVp(proofTypes: ldpVp.proofType)
        formats.append(ldpVpFormat)
      }
    }

    try self.init(values: formats)
  }

  // Convert VpFormats to JSON
  func toJSON() -> JSON {
    var mergedFormats: [String: JSON] = [:]

    for format in values {
      let jsonFormat = format.toJSON()

      // Assuming jsonFormat is [String: JSON] — merge it in
      for (key, value) in jsonFormat {
        mergedFormats[key] = value
      }
    }

    return JSON([Self.vpFormats: mergedFormats])
  }
}

// Extend VpFormat to convert to JSON
extension VpFormat {
  func toJSON() -> JSON {
    switch self {
    case .sdJwtVc(let sdJwtAlgorithms, let kbJwtAlgorithms):
      return JSON(["dc+sd-jwt": [
        "sd-jwt_alg_values": sdJwtAlgorithms.map { $0.name },
        "kb-jwt_alg_values": kbJwtAlgorithms.map { $0.name }
      ]]
      )
    case .msoMdoc(let algorithms):
      return JSON(["mso_mdoc": [
        "alg": algorithms.map { $0.name }
      ]
                  ])

    case .jwtVp(let algorithms):
      return JSON([
        "jwtVp": ["algorithms": algorithms]
      ])
    case .ldpVp(let proofTypes):
      return JSON([
        "ldpVp": ["proofTypes": proofTypes]
      ])
    }
  }
}

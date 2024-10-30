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

public struct VpFormatsTO: Codable, Equatable {
  public let vcSdJwt: VcSdJwtTO?
  public let jwtVp: JwtVpTO?
  public let ldpVp: LdpVpTO?
  public let msoMdoc: JSON?
  
  public init(
    vcSdJwt: VcSdJwtTO? = nil,
    jwtVp: JwtVpTO? = nil,
    ldpVp: LdpVpTO? = nil,
    msoMdoc: JSON? = nil
  ) {
    self.vcSdJwt = vcSdJwt
    self.jwtVp = jwtVp
    self.ldpVp = ldpVp
    self.msoMdoc = msoMdoc
  }
  
  enum CodingKeys: String, CodingKey {
    case vcSdJwt = "vc+sd-jwt"
    case jwtVp = "jwt_vp"
    case ldpVp = "ldp_vp"
    case msoMdoc = "mso_mdoc"
  }
}

public struct VcSdJwtTO: Codable, Equatable {
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

public struct JwtVpTO: Codable, Equatable {
  public let alg: [String]
  
  public init(alg: [String]) {
    self.alg = alg
  }
}

public struct LdpVpTO: Codable, Equatable {
  public let proofType: [String]
  
  enum CodingKeys: String, CodingKey {
    case proofType = "proof_type"
  }
  
  public init(proofType: [String]) {
    self.proofType = proofType
  }
}

public enum VpFormat: Equatable {
  
  case sdJwtVc(
    sdJwtAlgorithms: [JWSAlgorithm],
    kbJwtAlgorithms: [JWSAlgorithm]
  )
  case msoMdoc(JSON)
  case jwtVp(algorithms: [String])
  case ldpVp(proofTypes: [String])
  
  public static func createSdJwtVc(
    sdJwtAlgorithms: [JWSAlgorithm],
    kbJwtAlgorithms: [JWSAlgorithm]
  ) -> VpFormat {
    
    guard !sdJwtAlgorithms.isEmpty else {
      fatalError("SD-JWT algorithms cannot be empty")
    }
    
    return .sdJwtVc(
      sdJwtAlgorithms: sdJwtAlgorithms,
      kbJwtAlgorithms: kbJwtAlgorithms
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

public struct VpFormats: Equatable {
  
  static let formats = "vp_formats"
  public let values: [VpFormat]
  
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
    guard let metaData = json.dictionaryObject else {
      return nil
    }
    if let vpFormatsDictionary: JSON = try? metaData.getValue(
      for: Self.formats,
      error: ValidatedAuthorizationError.invalidClientMetadata
    ), let formats = vpFormatsDictionary.dictionary?.decode(to: VpFormatsTO.self) {
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
  
  private static func ensureUniquePerFormat(formats: [VpFormat]) throws {
    let groupedFormats = Dictionary(grouping: formats) { $0.formatName() }
    
    for (formatName, instances) in groupedFormats {
      guard instances.count == 1 else {
        throw ValidatedAuthorizationError.validationError("Multiple instances \(instances.count) found for \(formatName).")
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
    
    if let msoMdocJson = to.msoMdoc {
      let msoMdocFormat = VpFormat.msoMdoc(msoMdocJson)
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
  
  // Convert VpFormats to JSON
  func toJSON() -> JSON {
    var jsonArray: [JSON] = []
    
    for format in values {
      let jsonFormat = format.toJSON()
      jsonArray.append(jsonFormat)
    }
    
    return JSON([Self.formats: jsonArray])
  }
}

// Extend VpFormat to convert to JSON
extension VpFormat {
  func toJSON() -> JSON {
    switch self {
    case .sdJwtVc(let sdJwtAlgorithms, let kbJwtAlgorithms):
      return JSON([
        "type": "sdJwtVc",
        "sdJwtAlgorithms": sdJwtAlgorithms.map { $0.name }, // Assuming JWSAlgorithm has a `name` property
        "kbJwtAlgorithms": kbJwtAlgorithms.map { $0.name }
      ])
    case .msoMdoc(let json):
      return JSON([
        "type": "msoMdoc",
        "data": json
      ])
    case .jwtVp(let algorithms):
      return JSON([
        "type": "jwtVp",
        "algorithms": algorithms
      ])
    case .ldpVp(let proofTypes):
      return JSON([
        "type": "ldpVp",
        "proofTypes": proofTypes
      ])
    }
  }
}
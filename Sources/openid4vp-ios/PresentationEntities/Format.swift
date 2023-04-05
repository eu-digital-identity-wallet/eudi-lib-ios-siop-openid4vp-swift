import Foundation

public struct Format: Codable, Equatable {
  public let jwt: Jwt?
  public let jwtVc: Jwt?
  public let jwtVp: Jwt?
  public let msoMdoc: Jwt?
  public let ldpVc: Ldp?
  public let ldpVp: Ldp?
  public let ldp: Ldp?

  enum CodingKeys: String, CodingKey {
    case jwt
    case jwtVc = "jwt_vc"
    case jwtVp = "jwt_vp"
    case ldpVc = "ldp_vc"
    case ldpVp = "ldp_vp"
    case ldp
    case msoMdoc = "mso_mdoc"
  }
}

public struct Jwt: Codable, Equatable {
  public let alg: [String]
}

public struct Ldp: Codable, Equatable {
  public let proofType: [String]

  enum CodingKeys: String, CodingKey {
    case proofType = "proof_type"
  }
}

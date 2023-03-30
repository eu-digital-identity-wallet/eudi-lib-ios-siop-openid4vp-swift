import Foundation

struct Format: Codable, Equatable {
    let jwt, jwtVc, jwtVp: Jwt
    let ldpVc, ldpVp, ldp: Ldp

    enum CodingKeys: String, CodingKey {
        case jwt
        case jwtVc = "jwt_vc"
        case jwtVp = "jwt_vp"
        case ldpVc = "ldp_vc"
        case ldpVp = "ldp_vp"
        case ldp
    }
}

struct Jwt: Codable, Equatable {
    let alg: [String]
}

struct Ldp: Codable, Equatable {
    let proofType: [String]

    enum CodingKeys: String, CodingKey {
        case proofType = "proof_type"
    }
}

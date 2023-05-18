import Foundation

public enum FormatSpecifier: Codable, Equatable {
  case alg(Set<FormatAlgorithm>)
  case proofType(Set<LdpProof>)
  case none
}

public enum FormatAlgorithm: String, Codable {
  case HS256 // HMAC using SHA-256 (Required)
  case HS384 // HMAC using SHA-384
  case HS512 // HMAC using SHA-512
  case RS256 // RSASSA-PKCS1-v1_5 using SHA-256 (Recommended)
  case RS384 // RSASSA-PKCS1-v1_5 using SHA-384
  case RS512 // RSASSA-PKCS1-v1_5 using SHA-512
  case ES256 // ECDSA using P-256 and SHA-256 (Recommended)
  case ES256K
  case ES384 // ECDSA using P-384 and SHA-384
  case ES512 // ECDSA using P-521 and SHA-512
  case PS256 // RSASSA-PSS using SHA-256 and MGF1 with SHA-256
  case PS384
  case PS512
  case EDDSA = "EdDSA"
}

public enum LdpProof: String, Codable {
  case ed25519Signature2018 = "Ed25519Signature2018"
  case rsaSignature2018 = "RsaSignature2018"
  case rsaVerificationKey2018 = "RsaVerificationKey2018"
  case ecdsaSecp256k1Signature2019 = "EcdsaSecp256k1Signature2019"
  case ecdsaSecp256k1VerificationKey2019 = "EcdsaSecp256k1VerificationKey2019"
  case ecdsaSecp256k1RecoverySignature2020 = "EcdsaSecp256k1RecoverySignature2020"
  case ecdsaSecp256k1RecoveryMethod2020 = "EcdsaSecp256k1RecoveryMethod2020"
  case jsonWebSignature2020 = "JsonWebSignature2020"
  case jwsVerificationKey2020 = "JwsVerificationKey2020"
  case gpgSignature2020 = "GpgSignature2020"
  case gpgVerificationKey2020 = "GpgVerificationKey2020"
  case jcsEd25519Signature2020 = "JcsEd25519Signature2020"
  case jcsEd25519Key2020 = "JcsEd25519Key2020"
  case bbsBlsSignature2020 = "BbsBlsSignature2020"
  case bbsBlsSignatureProof2020 = "BbsBlsSignatureProof2020"
  case bls12381G1Key2020 = "Bls12381G1Key2020"
  case bls12381G2Key2020 = "Bls12381G2Key2020"
}

public enum FormatDesignation: String, Codable {

  case msoMdoc = "MSO_MDOC"
  case jwt = "JWT"
  case jwtVC = "JWT_VC"
  case jwtVp = "JWT_VP"

  case ldp = "LDP"
  case ldpVc = "LDP_VC"
  case ldpVp = "LDP_VP"
}

public struct FormatContainer: Codable, Equatable {
  public let formats: [Format]

  enum Key: String, CodingKey {
    case formats
  }

  public init(formats: [Format]) {
    self.formats = formats
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let dictionary = try container.decode([String: [String: [String]]].self)
    var parsed: [Format] = []

    for (key, value) in dictionary {
      let designation = key
      let properties: [String: [String]] = value

      if properties.count > 1 {
        throw ValidatedAuthorizationError.invalidFormat
      }

      for (key, value) in properties {
        guard let formatDesignation = FormatDesignation(rawValue: designation.uppercased()) else {
          throw ValidatedAuthorizationError.invalidFormat
        }

        var property: FormatSpecifier = .none
        var algs: [FormatAlgorithm] = []
        if key == "alg" {
          algs = value.compactMap { FormatAlgorithm(rawValue: $0) }
          if algs.isEmpty {
            throw ValidatedAuthorizationError.invalidFormat
          }

          property = .alg(Set(algs))
        }

        var proofs: [LdpProof] = []
        if key == "proof_type" {
          proofs = value.compactMap { LdpProof(rawValue: $0) }
          if proofs.isEmpty {
            throw ValidatedAuthorizationError.invalidFormat
          }

          property = .proofType(Set(proofs))
        }

        let format: Format = .init(
          designation: formatDesignation,
          property: property
        )

        switch property {
        case .none:
          throw ValidatedAuthorizationError.invalidFormat
        default: break
        }

        parsed.append(format)
      }
    }
    formats = parsed
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: Key.self)
    try? container.encode(formats, forKey: .formats)
  }
}

public struct Format: Codable, Equatable {
  public let designation: FormatDesignation
  public let property: FormatSpecifier

  enum CodingKeys: String, CodingKey {
    case designation
    case property
  }

  public static func == (lhs: Format, rhs: Format) -> Bool {
    return lhs.designation == rhs.designation && lhs.property == rhs.property
  }
}

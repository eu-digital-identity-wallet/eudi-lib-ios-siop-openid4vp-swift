import Foundation

public enum JwtType: String, Codable {
  case jwt
  case jwtVC = "JWT_VC"
  case jwtVP = "JWT_VP"
}

public enum LdpType: String, Codable {
  case ldp
  case ldpVc = "LDP_VC"
  case ldpVp = "LDP_VP"
}

public enum ClaimFormat {
  case msoMdoc
  case jwt(JwtType)
  case ldp(LdpType)
}

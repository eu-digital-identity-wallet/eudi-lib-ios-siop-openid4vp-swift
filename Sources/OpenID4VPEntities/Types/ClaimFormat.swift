public enum ClaimFormat: Equatable {
  case msoMdoc
  case jwtType(JWTType)
  case ldpType(LDPType)

  public enum JWTType {
    case jwt
    case jwt_vc
    case jwt_vp
  }

  public enum LDPType {
    case ldp
    case ldp_vc
    case ldp_vp
  }
}

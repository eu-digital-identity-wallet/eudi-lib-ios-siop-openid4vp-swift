import Foundation

public enum ResolvedSiopOpenId4VPRequestData {
  case idToken(request: IdTokenData)
  case vpToken(request: VpTokenData)
  case idAndVpToken(request: IdAndVpTokenData)
}

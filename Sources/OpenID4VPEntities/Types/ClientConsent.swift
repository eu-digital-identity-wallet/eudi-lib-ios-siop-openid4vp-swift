import Foundation
import PresentationExchange

/**
 Consent. Holder decided to respond to a request
  */
public enum ClientConsent {

  /**
   In response to a SiopAuthentication, Holder/Wallet provides a JWT
    - Parameters:
     - idToken: The id_token produced by the wallet
    */
  case idToken(idToken: JWTString)

  /**
   In response to an OpenId4VPAuthorization where the wallet has claims that fulfill Verifier's presentation definition
    - Parameters:
     - approvedClaims: The claims to include chosen by the holder
    */
  case vpToken(approvedClaims: [Claim])

  /**
   In response to a SiopOpenId4VPAuthentication
    - Parameters:
     - idToken: The id_token produced by the wallet
     - approvedClaims: The claims to include chosen by the holder
    */
  case idAndVPToken(approvedClaims: [Claim])

  /**
   No consensus. Holder decided to reject the request
    */
  case negative(message: String)
}

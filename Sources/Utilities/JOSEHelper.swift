import Foundation
import Security
import JOSESwift

public struct HolderInfo {
  let email: String
  let name: String
}

public class JOSEHelper {

  let error = NSError(
    domain: "niscy-eudiw.JOSEError",
    code: 103,
    userInfo: nil
  )

  public init() { }

  func jwtLoop() throws -> JWS {

    let kid = UUID().uuidString
    let privateKey = try self.getPrivateKey()
    let signer = try self.signer(algorithhm: .RS256, privateKey: privateKey)
    let header = try JWSHeader(parameters: [
      "alg": SignatureAlgorithm.RS256.rawValue,
      "kid": kid
    ])

    let jsonPayloadData: Data = try [
      "key1": "value1",
      "key2": "value2"
    ].toThrowingJSONData()

    let payload = Payload(jsonPayloadData)
    let compactSerializedJWS = try JWS(
      header: header,
      payload: payload,
      signer: signer
    ).compactSerializedString

    let publicKey = try getPublicKey(from: privateKey)
    let jws = try getJWS(compactSerialization: compactSerializedJWS)
    let verifier = try self.verifier(algorithhm: .RS256, publicKey: publicKey)

    let jwk = try RSAPublicKey(publicKey: publicKey, additionalParameters: [
      "use": "sig",
      "kid": kid,
      "iat": "3672123"
    ])

    _ = JWKSet(keys: [jwk])

    let thumbprint = try jwk.thumbprint(algorithm: .SHA256)
    print(thumbprint)

    return try jws.validate(using: verifier)
  }

  func generateRandomPublicKey() throws -> RSAPublicKey {
    let attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
      kSecAttrKeySizeInBits as String: 2048
    ]

    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
      throw error!.takeRetainedValue() as Error
    }

    guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
      throw NSError(domain: NSOSStatusErrorDomain, code: Int(errSecParam), userInfo: nil)
    }

    do {
      return try RSAPublicKey(publicKey: publicKey)
    } catch {
      throw error
    }
  }

  func build(
    request: ResolvedSiopOpenId4VPRequestData
  ) {

  }
}

private extension JOSEHelper {

  func verifier(algorithhm: SignatureAlgorithm, publicKey: SecKey) throws -> Verifier {
    guard let verifier = Verifier(verifyingAlgorithm: .RS256, key: publicKey) else {
      throw error
    }
    return verifier
  }

  func getJWS(compactSerialization: String) throws -> JWS {
    guard let jws = try? JWS(compactSerialization: compactSerialization) else {
      throw error
    }
    return jws
  }

  func getPublicKey(from privateKey: SecKey) throws -> SecKey {
    guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
      throw error
    }
    return publicKey
  }

  func getPrivateKey() throws -> SecKey {
    let attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
      kSecAttrKeySizeInBits as String: 2048
    ]

    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
      throw error!.takeRetainedValue() as Error
    }
    return privateKey
  }

  func signer(algorithhm: SignatureAlgorithm, privateKey: SecKey) throws -> Signer<SecKey> {
    guard let signer = Signer(signingAlgorithm: algorithhm, key: privateKey) else {
      throw error
    }
    return signer
  }
}

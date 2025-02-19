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
import PresentationExchange
import CryptoKit

@testable import SiopOpenID4VP

struct TestsConstants {
  
  public static func testClientMetaData() -> ClientMetaData {
    .init(
      jwksUri: "https://jwks.uri",
      jwks: "jwks",
      idTokenSignedResponseAlg: ".idTokenSignedResponseAlg",
      idTokenEncryptedResponseAlg: ".idTokenEncryptedResponseAlg",
      idTokenEncryptedResponseEnc: ".idTokenEncryptedResponseEnc",
      subjectSyntaxTypesSupported: [],
      authorizationSignedResponseAlg: ".authorizationSignedResponseAlg",
      authorizationEncryptedResponseAlg: ".authorizationEncryptedResponseAlg",
      authorizationEncryptedResponseEnc: ".authorizationEncryptedResponseEnc",
      vpFormats: Self.testVpFormatsTO()
    )
  }
  
  public static func testValidatedClientMetaData() -> ClientMetaData.Validated {
    .init(
      jwkSet: webKeySet,
      idTokenJWSAlg: .init(.ES256),
      idTokenJWEAlg: .init(.A128GCMKW),
      idTokenJWEEnc: .init(.A128CBC_HS256),
      subjectSyntaxTypesSupported: [.decentralizedIdentifier],
      authorizationSignedResponseAlg: .init(.ES256),
      authorizationEncryptedResponseAlg: .init(.A128GCMKW),
      authorizationEncryptedResponseEnc: .init(.A128CBC_HS256),
      vpFormats: try! VpFormats(from: TestsConstants.testVpFormatsTO())!
    )
  }

  public static let testPresentationId = "32f54163-7166-48f1-93d8-ff217bdb0653"
  public static let testPresentationSubmission: PresentationSubmission = .init(
    id: "028b39fd-33b6-46a1-8887-2ef654771d7f",
    definitionID: TestsConstants.testPresentationId,
    descriptorMap: [
      .init(
        id: "eu.europa.ec.eudi.pid.1",
        format: "mso_mdoc",
        path: "$"
      )
    ]
  )
  
  public static let testClientId = "dev.verifier-backend.eudiw.dev"
  public static let clientId = "x509_san_dns:\(Self.testClientId)"
  
  public static let testNonce = "0S6_WzA2Mj"
  public static let testScope = "one two three"

  public static let testResponseMode: ResponseMode = .directPost(responseURI: URL(string: "https://respond.here")!)

  static func generateRandomJWT() -> String {
    // Define the header
    let header = #"{"alg":"HS256","typ":"JWT"}"#

    // Define the claims
    let claims = #"{"iss":"issuer","sub":"subject","aud":["audience"],"exp":1679911600,"iat":1657753200}"#

    // Create the base64url-encoded segments
    let encodedHeader = header.base64urlEncode
    let encodedClaims = claims.base64urlEncode

    // Concatenate the header and claims segments with a dot separator
    let encodedToken = "\(encodedHeader).\(encodedClaims)"

    // Define the secret key for signing
    let secretKey = "your_secret_key".data(using: .utf8)!

    // Sign the token with HMAC-SHA256
    let signature = HMAC<SHA256>.authenticationCode(for: Data(encodedToken.utf8), using: SymmetricKey(data: secretKey))

    // Base64url-encode the signature
    let encodedSignature = Data(signature).base64EncodedString()

    // Concatenate the encoded token and signature with a dot separator
    let jwt = "\(encodedToken).\(encodedSignature)"

    return jwt
  }

  static func generateRandomBase64String() -> String? {
    let randomData = Data.randomData(length: 32)
    let base64URL = randomData.base64URLEncodedString()
    return base64URL
  }
  
  // MARK: - Claims
  
  static let sampleClientMetaData = #"{"jwks_uri":"value_jwks_uri","id_token_signed_response_alg":"value_id_token_signed_response_alg","id_token_encrypted_response_alg":"value_id_token_encrypted_response_alg","id_token_encrypted_response_enc":"value_id_token_encrypted_response_enc","subject_syntax_types_supported":["value_subject_syntax_types_supported"]}"#
  
  static let sampleValidClientMetaData = #"{"jwks":{"keys":[{"kty":"RSA", "e":"AQAB", "use":"sig", "kid":"a4e1bbe6-26e8-480b-a364-f43497894453", "iat":1683559586, "n":"xHI9zoXS-fOAFXDhDmPMmT_UrU1MPimy0xfP-sL0Iu4CQJmGkALiCNzJh9v343fqFT2hfrbigMnafB2wtcXZeEDy6Mwu9QcJh1qLnklW5OOdYsLJLTyiNwMbLQXdVxXiGby66wbzpUymrQmT1v80ywuYd8Y0IQVyteR2jvRDNxy88bd2eosfkUdQhNKUsUmpODSxrEU2SJCClO4467fVdPng7lyzF2duStFeA2vUkZubor3EcrJ72JbZVI51YDAqHQyqKZIDGddOOvyGUTyHz9749bsoesqXHOugVXhc2elKvegwBik3eOLgfYKJwisFcrBl62k90RaMZpXCxNO4Ew"}]},"id_token_signed_response_alg":"value_id_token_signed_response_alg","id_token_encrypted_response_alg":"value_id_token_encrypted_response_alg","id_token_encrypted_response_enc":"value_id_token_encrypted_response_enc","subject_syntax_types_supported":["value_subject_syntax_types_supported"]}"#
  
  static let sampleValidJWKS = #"{"keys":[{"kty":"RSA", "e":"AQAB", "use":"sig", "kid":"9556a7a5-bb4f-4354-9208-74789528d1c7", "iat":1691595131, "n":"087NDoY9u7QUYAd-hjzx0B7k5_jofB1-wgRWGpFtpFmBkWMPCHtH72E240xkEO_nrgyEPJvh5-K6V--9MHevBCw1ihR-GtiCK4LEtY6alTWJx90yFEwiwHqVTzWpGDZSyRb3QGgjSgqWlYeIHkro58EykYyVCXr9m5PuyiM1Uekt6PXAZdWYFBeT8v1bjwe8knVEayC7U5eVkScabGcGGUWRFeOVbkS6vR18PCJ8nokHQipISpgD2pdD29Vn39Aped3hd7tdVJj-C7qZwIuAEUeRzxXeKdLRxmZvj_oX_Q39XzNVpMVO8IQSrKvqPKvQUNABboxb24L7pK1b9F0S4w"}]}"#
  
  static let testClaimsBankAndPassport = [
    Claim(
      id: "samplePassport",
      format: "ldp",
      jsonObject: [
        "credentialSchema":
          [
            "id": "hub://did:foo:123/Collections/schema.us.gov/passport.json"
          ],
        "credentialSubject":
          [
            "birth_date":"1974-11-11",
          ]
      ]
    ),
    Claim(
      id: "sampleBankAccount",
      format: "jwt",
      jsonObject: [
        "issuer": "did:example:123",
        "credentialSchema":
          [
            "id": "https://bank-standards.example.com/fullaccountroute.json"
          ]
      ]
    )
  ]
  
  // MARK: - Client meta data by value, Presentation definition by reference
  
  static let validVpTokenByClientByValuePresentationByReferenceUrlString =
  "eudi-wallet://authorize?" +
  "response_type=vp_token" +
  "&client_id=verifier-backend.eudiw.dev" +
  "&client_id_scheme=pre-registered" +
  "&client_metadata={\"jwks_uri\":\"value_jwks_uri\",\"id_token_signed_respons e_alg\":\"value_id_token_signed_response_alg\",\"id_token_encrypted_response_alg\":\"value_id_token_encrypted_response_alg\",\"id_token_encrypted_response_enc\":\"value_id_token_encrypted_response_enc\",\"subject_syntax_types_supported\":[\"value_subject_syntax_types_supported\"],\"vp_formats\":{\"vc+sd-jwt\":{\"sd-jwt_alg_values\":[\"ES256\"],\"kb-jwt_alg_values\":[\"ES256\"]}}" +
  "&redirect_uri=https://client.example.org/redirect_me" +
  "&presentation_definition={\"comment\":\"Note: VP, OIDC, DIDComm, or CHAPI outer wrapper would be here.\",\"presentation_definition\":{\"id\":\"8e6ad256-bd03-4361-a742-377e8cccced0\",\"name\":\"Presentation definition 002\",\"purpose\":\"Account info 002\",\"input_descriptors\":[{\"id\":\"wa_driver_license\",\"name\":\"Washington State Business License\",\"purpose\":\"We can only allow licensed Washington State business representatives into the WA Business Conference\",\"constraints\":{\"fields\":[{\"path\":[\"$.credentialSubject.dateOfBirth\",\"$.credentialSubject.dob\",\"$.vc.credentialSubject.dateOfBirth\",\"$.vc.credentialSubject.dob\"]}]}}]}}" +
  "&nonce=n-0S6_WzA2Mj" +
  "&response_mode=direct_post" +
  "&response_uri=https://client.example.org/response"
  
  static var validVpTokenByClientByValuePresentationByReferenceUrl: URL {
    return URL(string: validVpTokenByClientByValuePresentationByReferenceUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    )!
  }
  
  static let validIdTokenByClientByValuePresentationByReferenceUrlString =
  "eudi-wallet://authorize?" +
  "response_type=id_token" +
  "&client_id=verifier-backend.eudiw.dev" +
  "&client_id_scheme=pre-registered" +
  "&client_metadata={\"jwks_uri\":\"value_jwks_uri\",\"id_token_signed_response_alg\":\"value_id_token_signed_response_alg\",\"id_token_encrypted_response_alg\":\"value_id_token_encrypted_response_alg\",\"id_token_encrypted_response_enc\":\"value_id_token_encrypted_response_enc\",\"subject_syntax_types_supported\":[\"value_subject_syntax_types_supported\"],\"vp_formats\":{\"vc+sd-jwt\":{\"sd-jwt_alg_values\":[\"ES256\"],\"kb-jwt_alg_values\":[\"ES256\"]}}}" +
  "&redirect_uri=https://client.example.org/redirect_me" +
  "&presentation_definition={\"comment\":\"Note: VP, OIDC, DIDComm, or CHAPI outer wrapper would be here.\",\"presentation_definition\":{\"id\":\"8e6ad256-bd03-4361-a742-377e8cccced0\",\"name\":\"Presentation definition 002\",\"purpose\":\"Account info 002\",\"input_descriptors\":[{\"id\":\"wa_driver_license\",\"name\":\"Washington State Business License\",\"purpose\":\"We can only allow licensed Washington State business representatives into the WA Business Conference\",\"constraints\":{\"fields\":[{\"path\":[\"$.credentialSubject.dateOfBirth\",\"$.credentialSubject.dob\",\"$.vc.credentialSubject.dateOfBirth\",\"$.vc.credentialSubject.dob\"]}]}}]}}" +
  "&nonce=n-0S6_WzA2Mj" +
  "&response_mode=direct_post" +
  "&id_token_type=subject_signed" +
  "&response_uri=https://client.example.org/response"
  
  static var validIdTokenByClientByValuePresentationByReferenceUrl: URL {
    return URL(string: validIdTokenByClientByValuePresentationByReferenceUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    )!
  }
  
  static let validIdVpTokenByClientByValuePresentationByReferenceUrlString =
  "eudi-wallet://authorize?" +
  "response_type=vp_token id_token" +
  "&client_id=verifier-backend.eudiw.dev" +
  "&client_id_scheme=pre-registered" +
  "&client_metadata={\"jwks\":{\"keys\":[{\"kty\":\"RSA\", \"e\":\"AQAB\", \"use\":\"sig\", \"kid\":\"a4e1bbe6-26e8-480b-a364-f43497894453\", \"iat\":1683559586, \"n\":\"xHI9zoXS-fOAFXDhDmPMmT_UrU1MPimy0xfP-sL0Iu4CQJmGkALiCNzJh9v343fqFT2hfrbigMnafB2wtcXZeEDy6Mwu9QcJh1qLnklW5OOdYsLJLTyiNwMbLQXdVxXiGby66wbzpUymrQmT1v80ywuYd8Y0IQVyteR2jvRDNxy88bd2eosfkUdQhNKUsUmpODSxrEU2SJCClO4467fVdPng7lyzF2duStFeA2vUkZubor3EcrJ72JbZVI51YDAqHQyqKZIDGddOOvyGUTyHz9749bsoesqXHOugVXhc2elKvegwBik3eOLgfYKJwisFcrBl62k90RaMZpXCxNO4Ew\"}]},\"id_token_signed_response_alg\":\"value_id_token_signed_response_alg\",\"id_token_encrypted_response_alg\":\"value_id_token_encrypted_response_alg\",\"id_token_encrypted_response_enc\":\"value_id_token_encrypted_response_enc\",\"subject_syntax_types_supported\":[\"value_subject_syntax_types_supported\"],\"vp_formats\":{\"vc+sd-jwt\":{\"sd-jwt_alg_values\":[\"ES256\"],\"kb-jwt_alg_values\":[\"ES256\"]}}}" +
  "&redirect_uri=https://client.example.org/redirect_me" +
  "&presentation_definition={\"comment\":\"Note: VP, OIDC, DIDComm, or CHAPI outer wrapper would be here.\",\"presentation_definition\":{\"id\":\"8e6ad256-bd03-4361-a742-377e8cccced0\",\"name\":\"Presentation definition 002\",\"purpose\":\"Account info 002\",\"input_descriptors\":[{\"id\":\"wa_driver_license\",\"name\":\"Washington State Business License\",\"purpose\":\"We can only allow licensed Washington State business representatives into the WA Business Conference\",\"constraints\":{\"fields\":[{\"path\":[\"$.credentialSubject.dateOfBirth\",\"$.credentialSubject.dob\",\"$.vc.credentialSubject.dateOfBirth\",\"$.vc.credentialSubject.dob\"]}]}}]}}" +
  "&nonce=n-0S6_WzA2Mj" +
  "&response_mode=direct_post" +
  "&id_token_type=subject_signed" +
  "&response_uri=https://client.example.org/response"
  
  static var validIdVpTokenByClientByValuePresentationByReferenceUrl: URL {
    return URL(string: validIdVpTokenByClientByValuePresentationByReferenceUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    )!
  }
  
  // MARK: - Client meta data by reference, Presentation definition by reference
  
  static let validByClientByReferencePresentationByReferenceUrlString =
  "eudi-wallet://authorize?" +
  "response_type=vp_token" +
  "&client_id=https://client.example.org/" +
  "&client_id_scheme=pre-registered" +
  "&client_metadata_uri=https://client.example.org/redirect_me" +
  "&redirect_uri=https://client.example.org/redirect_me" +
  "&presentation_definition={\"comment\":\"Note: VP, OIDC, DIDComm, or CHAPI outer wrapper would be here.\",\"presentation_definition\":{\"id\":\"8e6ad256-bd03-4361-a742-377e8cccced0\",\"name\":\"Presentation definition 002\",\"purpose\":\"Account info 002\",\"input_descriptors\":[{\"id\":\"wa_driver_license\",\"name\":\"Washington State Business License\",\"purpose\":\"We can only allow licensed Washington State business representatives into the WA Business Conference\",\"constraints\":{\"fields\":[{\"path\":[\"$.credentialSubject.dateOfBirth\",\"$.credentialSubject.dob\",\"$.vc.credentialSubject.dateOfBirth\",\"$.vc.credentialSubject.dob\"]}]}}]}}" +
  "&nonce=n-0S6_WzA2Mj" +
  "&response_mode=direct_post" +
  "&response_uri=https://client.example.org/response"
  
  static var validByClientByReferencePresentationByReferenceUrl: URL {
    return URL(string: validByClientByReferencePresentationByReferenceUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
  }
  
  // MARK: - Invalid URL
  
  static let invalidUrlString =
  "eudi-wallet://authorized?test_key=testvalue"
  
  static var invalidUrl: URL {
    return URL(string: invalidUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
  }
  
  // MARK: - Request objects
  
  static let requestUriUrlString =
  "https://eudi.netcompany-intrasoft.com?client_id=Verifier&request_uri=https://eudi.netcompany-intrasoft.com/wallet/request.jwt/j8fZmNb-VpQ73yD4WduQKB3YKxgG_tQ3geW96u20fwhjBXG02oeS3Y85Lv8IbWAvePrvT7W8pMUXnCGtgToqzw"
  
  static var requestUriUrl: URL {
    return URL(string: requestUriUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
  }
  
  static let requestExpiredUrlString =
  "eudi-wallet://authorized?request_uri=https://eudi.netcompany-intrasoft.com/wallet/request.jwt/T9ZNgzH5XckvyABisd5lja-5PfUSn9or52Qg4sjb8s3qjb5gi9B1oSOtlU6XI4Y13YISeiHRlcVoSWpFafOI8g"
  
  static var requestExpiredUrl: URL {
    return URL(string: requestExpiredUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
  }
  
  static let requestObjectUrlString =
  "eudi-wallet://authorized?request=eyJraWQiOiIzOWY0NGQzOS0wMzQ4LTRmNzktYjQ1Yy1jNTExMDkyNTU1NjYiLCJhbGciOiJSUzI1NiJ9.eyJyZXNwb25zZV91cmkiOiJodHRwczovL2ZvbyIsImNsaWVudF9pZF9zY2hlbWUiOiJwcmUtcmVnaXN0ZXJlZCIsInJlc3BvbnNlX3R5cGUiOiJ2cF90b2tlbiIsIm5vbmNlIjoiSEhqRDdiMGxMQVh0X0VNVk5EU1c2cHl2blowM05yYlJtSzBKMFJMUHozSlNZY01jMGhfeVZmYkd3VDRuWWtRYzNFR0FYWFNWS1pITkZmNGs5N3ZrdHciLCJjbGllbnRfaWQiOiJWZXJpZmllciIsInJlc3BvbnNlX21vZGUiOiJkaXJlY3RfcG9zdC5qd3QiLCJhdWQiOiJodHRwczovL3NlbGYtaXNzdWVkLm1lL3YyIiwic2NvcGUiOiIiLCJwcmVzZW50YXRpb25fZGVmaW5pdGlvbiI6eyJpZCI6IjMyZjU0MTYzLTcxNjYtNDhmMS05M2Q4LWZmMjE3YmRiMDY1MyIsImlucHV0X2Rlc2NyaXB0b3JzIjpbeyJpZCI6ImJhbmthY2NvdW50X2lucHV0IiwibmFtZSI6IkZ1bGwgQmFuayBBY2NvdW50IFJvdXRpbmcgSW5mb3JtYXRpb24iLCJwdXJwb3NlIjoiV2UgY2FuIG9ubHkgcmVtaXQgcGF5bWVudCB0byBhIGN1cnJlbnRseS12YWxpZCBiYW5rIGFjY291bnQsIHN1Ym1pdHRlZCBhcyBhbiBBQkEgUlROICsgQWNjdCAgb3IgSUJBTi4iLCJjb25zdHJhaW50cyI6eyJmaWVsZHMiOlt7InBhdGgiOlsiJC5jcmVkZW50aWFsU2NoZW1hLmlkIiwiJC52Yy5jcmVkZW50aWFsU2NoZW1hLmlkIl0sImZpbHRlciI6eyJ0eXBlIjoic3RyaW5nIiwiY29uc3QiOiJodHRwczovL2Jhbmstc3RhbmRhcmRzLmV4YW1wbGUuY29tL2Z1bGxhY2NvdW50cm91dGUuanNvbiJ9fSx7InBhdGgiOlsiJC5pc3N1ZXIiLCIkLnZjLmlzc3VlciIsIiQuaXNzIl0sInB1cnBvc2UiOiJXZSBjYW4gb25seSB2ZXJpZnkgYmFuayBhY2NvdW50cyBpZiB0aGV5IGFyZSBhdHRlc3RlZCBieSBhIHRydXN0ZWQgYmFuaywgYXVkaXRvciwgb3IgcmVndWxhdG9yeSBhdXRob3JpdHkuIiwiZmlsdGVyIjp7InR5cGUiOiJzdHJpbmciLCJwYXR0ZXJuIjoiZGlkOmV4YW1wbGU6MTIzfGRpZDpleGFtcGxlOjQ1NiJ9LCJpbnRlbnRfdG9fcmV0YWluIjp0cnVlfV19fSx7ImlkIjoidXNfcGFzc3BvcnRfaW5wdXQiLCJuYW1lIjoiVVMgUGFzc3BvcnQiLCJjb25zdHJhaW50cyI6eyJmaWVsZHMiOlt7InBhdGgiOlsiJC5jcmVkZW50aWFsU2NoZW1hLmlkIiwiJC52Yy5jcmVkZW50aWFsU2NoZW1hLmlkIl0sImZpbHRlciI6eyJ0eXBlIjoic3RyaW5nIiwiY29uc3QiOiJodWI6Ly9kaWQ6Zm9vOjEyMy9Db2xsZWN0aW9ucy9zY2hlbWEudXMuZ292L3Bhc3Nwb3J0Lmpzb24ifX0seyJwYXRoIjpbIiQuY3JlZGVudGlhbFN1YmplY3QuYmlydGhfZGF0ZSIsIiQudmMuY3JlZGVudGlhbFN1YmplY3QuYmlydGhfZGF0ZSIsIiQuYmlydGhfZGF0ZSJdLCJmaWx0ZXIiOnsidHlwZSI6InN0cmluZyIsImZvcm1hdCI6ImRhdGUifX1dfX1dfSwic3RhdGUiOiI5WTdNbnNEYVhBa2djejBwR19oVTFoUGZlQkVlTzFMaWJrWDdab3VLUHB3a05DNmI3WW1laW40MUN1VWszLUVvekw2TXVYcVhtcjVnTzRlaGNER0VxdyIsImlhdCI6MTY4MjcwNzE3OCwiY2xpZW50X21ldGFkYXRhIjp7Imp3a3NfdXJpIjoiaHR0cHM6Ly9qd2siLCJpZF90b2tlbl9zaWduZWRfcmVzcG9uc2VfYWxnIjoiUlMyNTYiLCJpZF90b2tlbl9lbmNyeXB0ZWRfcmVzcG9uc2VfYWxnIjoiUlMyNTYiLCJpZF90b2tlbl9lbmNyeXB0ZWRfcmVzcG9uc2VfZW5jIjoiQTEyOENCQy1IUzI1NiIsInN1YmplY3Rfc3ludGF4X3R5cGVzX3N1cHBvcnRlZCI6WyJ1cm46aWV0ZjpwYXJhbXM6b2F1dGg6andrLXRodW1icHJpbnQiLCJkaWQ6ZXhhbXBsZSIsImRpZDprZXkiXX19.jgrGjBcDTP5NlON2iYDQOdbr8h5vKLlbROeqg5JbBzRt3o0NIdb-KTCyB5msO9nLjVCnG6GnxfoUgOxUwpl1eKAvI0jpNDwba0jKFZec9AvBT-nSrMGrLKBEj83l2-yV8k1dH-CxKw19_td2bzfUjTYE_jJQPzpQ3ghLRUKVGslOOiScNq39L02O2eMOC00nxkMq6bBAzHUAcBt4-eZ4xd8Chgq7mqsx-phsiMCQ2sPEXTNNECreQrGDVnWAfRKoHVIfzD7ibKhJb8owN2Zs8KyFpMggdaeLHZ2Ce8VoqFFguuIlP8kf9r1p9KgF2gywIbdm0NPzbReWGNZWBiYj_g"
  
  static var requestObjectUrl: URL {
    return URL(string: requestObjectUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
  }
  
  static var passByValueJWTURI = "https://us-central1-dx4b-4c2d8.cloudfunctions.net/api_ecommbx/request_jwt/mock_001"
  static var passByValueJWT = "eyJraWQiOiIzOWY0NGQzOS0wMzQ4LTRmNzktYjQ1Yy1jNTExMDkyNTU1NjYiLCJhbGciOiJSUzI1NiJ9.eyJyZXNwb25zZV91cmkiOiJodHRwczovL2ZvbyIsImNsaWVudF9pZF9zY2hlbWUiOiJwcmUtcmVnaXN0ZXJlZCIsInJlc3BvbnNlX3R5cGUiOiJ2cF90b2tlbiIsIm5vbmNlIjoiSEhqRDdiMGxMQVh0X0VNVk5EU1c2cHl2blowM05yYlJtSzBKMFJMUHozSlNZY01jMGhfeVZmYkd3VDRuWWtRYzNFR0FYWFNWS1pITkZmNGs5N3ZrdHciLCJjbGllbnRfaWQiOiJWZXJpZmllciIsInJlc3BvbnNlX21vZGUiOiJkaXJlY3RfcG9zdC5qd3QiLCJhdWQiOiJodHRwczovL3NlbGYtaXNzdWVkLm1lL3YyIiwic2NvcGUiOiIiLCJwcmVzZW50YXRpb25fZGVmaW5pdGlvbiI6eyJpZCI6IjMyZjU0MTYzLTcxNjYtNDhmMS05M2Q4LWZmMjE3YmRiMDY1MyIsImlucHV0X2Rlc2NyaXB0b3JzIjpbeyJpZCI6ImJhbmthY2NvdW50X2lucHV0IiwibmFtZSI6IkZ1bGwgQmFuayBBY2NvdW50IFJvdXRpbmcgSW5mb3JtYXRpb24iLCJwdXJwb3NlIjoiV2UgY2FuIG9ubHkgcmVtaXQgcGF5bWVudCB0byBhIGN1cnJlbnRseS12YWxpZCBiYW5rIGFjY291bnQsIHN1Ym1pdHRlZCBhcyBhbiBBQkEgUlROICsgQWNjdCAgb3IgSUJBTi4iLCJjb25zdHJhaW50cyI6eyJmaWVsZHMiOlt7InBhdGgiOlsiJC5jcmVkZW50aWFsU2NoZW1hLmlkIiwiJC52Yy5jcmVkZW50aWFsU2NoZW1hLmlkIl0sImZpbHRlciI6eyJ0eXBlIjoic3RyaW5nIiwiY29uc3QiOiJodHRwczovL2Jhbmstc3RhbmRhcmRzLmV4YW1wbGUuY29tL2Z1bGxhY2NvdW50cm91dGUuanNvbiJ9fSx7InBhdGgiOlsiJC5pc3N1ZXIiLCIkLnZjLmlzc3VlciIsIiQuaXNzIl0sInB1cnBvc2UiOiJXZSBjYW4gb25seSB2ZXJpZnkgYmFuayBhY2NvdW50cyBpZiB0aGV5IGFyZSBhdHRlc3RlZCBieSBhIHRydXN0ZWQgYmFuaywgYXVkaXRvciwgb3IgcmVndWxhdG9yeSBhdXRob3JpdHkuIiwiZmlsdGVyIjp7InR5cGUiOiJzdHJpbmciLCJwYXR0ZXJuIjoiZGlkOmV4YW1wbGU6MTIzfGRpZDpleGFtcGxlOjQ1NiJ9LCJpbnRlbnRfdG9fcmV0YWluIjp0cnVlfV19fSx7ImlkIjoidXNfcGFzc3BvcnRfaW5wdXQiLCJuYW1lIjoiVVMgUGFzc3BvcnQiLCJjb25zdHJhaW50cyI6eyJmaWVsZHMiOlt7InBhdGgiOlsiJC5jcmVkZW50aWFsU2NoZW1hLmlkIiwiJC52Yy5jcmVkZW50aWFsU2NoZW1hLmlkIl0sImZpbHRlciI6eyJ0eXBlIjoic3RyaW5nIiwiY29uc3QiOiJodWI6Ly9kaWQ6Zm9vOjEyMy9Db2xsZWN0aW9ucy9zY2hlbWEudXMuZ292L3Bhc3Nwb3J0Lmpzb24ifX0seyJwYXRoIjpbIiQuY3JlZGVudGlhbFN1YmplY3QuYmlydGhfZGF0ZSIsIiQudmMuY3JlZGVudGlhbFN1YmplY3QuYmlydGhfZGF0ZSIsIiQuYmlydGhfZGF0ZSJdLCJmaWx0ZXIiOnsidHlwZSI6InN0cmluZyIsImZvcm1hdCI6ImRhdGUifX1dfX1dfSwic3RhdGUiOiI5WTdNbnNEYVhBa2djejBwR19oVTFoUGZlQkVlTzFMaWJrWDdab3VLUHB3a05DNmI3WW1laW40MUN1VWszLUVvekw2TXVYcVhtcjVnTzRlaGNER0VxdyIsImlhdCI6MTY4MjcwNzE3OCwiY2xpZW50X21ldGFkYXRhIjp7Imp3a3NfdXJpIjoiaHR0cHM6Ly9qd2siLCJpZF90b2tlbl9zaWduZWRfcmVzcG9uc2VfYWxnIjoiUlMyNTYiLCJpZF90b2tlbl9lbmNyeXB0ZWRfcmVzcG9uc2VfYWxnIjoiUlMyNTYiLCJpZF90b2tlbl9lbmNyeXB0ZWRfcmVzcG9uc2VfZW5jIjoiQTEyOENCQy1IUzI1NiIsInN1YmplY3Rfc3ludGF4X3R5cGVzX3N1cHBvcnRlZCI6WyJ1cm46aWV0ZjpwYXJhbXM6b2F1dGg6andrLXRodW1icHJpbnQiLCJkaWQ6ZXhhbXBsZSIsImRpZDprZXkiXX19.jgrGjBcDTP5NlON2iYDQOdbr8h5vKLlbROeqg5JbBzRt3o0NIdb-KTCyB5msO9nLjVCnG6GnxfoUgOxUwpl1eKAvI0jpNDwba0jKFZec9AvBT-nSrMGrLKBEj83l2-yV8k1dH-CxKw19_td2bzfUjTYE_jJQPzpQ3ghLRUKVGslOOiScNq39L02O2eMOC00nxkMq6bBAzHUAcBt4-eZ4xd8Chgq7mqsx-phsiMCQ2sPEXTNNECreQrGDVnWAfRKoHVIfzD7ibKhJb8owN2Zs8KyFpMggdaeLHZ2Ce8VoqFFguuIlP8kf9r1p9KgF2gywIbdm0NPzbReWGNZWBiYj_g"
  
  static var nonNormativeUrlString =
  "eudi-wallet://authorize?" +
  "response_type=vp_token" +
  "&client_id=verifier-backend.eudiw.dev" +
  "&client_id_scheme=pre-registered" +
  "&redirect_uri=https://client.example.org/" +
  "&presentation_definition=%@" +
  "&nonce=n-0S6_WzA2Mj"
  
  static var nonNormativeOutOfScopeUrlString =
  "https://www.example.com/authorize?" +
  "response_type=vp_token" +
  "&client_id=verifier-backend.eudiw.dev" +
  "&client_id_scheme=redirect_uri" +
  "&redirect_uri=https://client.example.org/" +
  "&presentation_definition=%@" +
  "&nonce=n-0S6_WzA2Mj"
  
  static var nonNormativeByReferenceUrlString =
  "eudi-wallet://authorize?" +
  "response_type=vp_token" +
  "&client_id=https://client.example.org/" +
  "&client_id_scheme=pre-registered" +
  "&redirect_uri=https://client.example.org/" +
  "&presentation_definition_uri=%@" +
  "&nonce=n-0S6_WzA2Mj"
  
  static var nonNormativeScopesUrlString =
  "https://www.example.com/authorize?" +
  "response_type=vp_token" +
  "&client_id=https://client.example.org/" +
  "&client_id_scheme=pre-registered" +
  "&redirect_uri=https://client.example.org/" +
  "&scope=%@" +
  "&nonce=n-0S6_WzA2Mj"
  
  static var validOutOfScopeAuthorizeUrl: URL {

    let presentationDefinitionJson = try! String(
      contentsOf: Bundle.module.url(forResource: "minimal_example", withExtension: "json")!
    )
    
    let encodedUrlString = String(
      format: nonNormativeOutOfScopeUrlString,
      presentationDefinitionJson).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed
      )!
    
    return URL(string: encodedUrlString)!
  }
  
  static var validAuthorizeUrl: URL {
    let presentationDefinitionJson = try! String(
      contentsOf: Bundle.module.url(forResource: "minimal_example", withExtension: "json")!
    )
    
    let encodedUrlString = String(
      format: nonNormativeUrlString,
      presentationDefinitionJson).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed
      )!
    
    return URL(string: encodedUrlString)!
  }
  
  static var validMatchAuthorizeUrl: URL {
    let presentationDefinitionJson = try! String(
      contentsOf: Bundle.module.url(forResource: "basic_example", withExtension: "json")!
    )
    
    let encodedUrlString = String(
      format: nonNormativeUrlString,
      presentationDefinitionJson).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed
      )!
    
    return URL(string: encodedUrlString)!
  }
  
  static var validByReferenceAuthorizeUrl: URL {
    let urlString = String(
      format: nonNormativeByReferenceUrlString,
      "https://us-central1-dx4b-4c2d8.cloudfunctions.net/api_ecommbx/presentation_definition/32f54163-7166-48f1-93d8-ff217bdb0653"
    )
    
    return URL(string: urlString)!
  }
  
  static var validByScopesAuthorizeUrl: URL {
    let urlString = String(
      format: nonNormativeScopesUrlString,
      "com.example.input_descriptors_example"
    )
    
    return URL(string: urlString)!
  }
  
  static var invalidAuthorizeUrl: URL {
    let encodedUrlString = String(
      format: nonNormativeUrlString, "THIS IS NOT JSON").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed
      )!
    
    return URL(string: encodedUrlString)!
  }
  
  static let webKeyJson = """
{
  "keys": [
    {
      "kty": "EC",
      "x5t#S256": "fwMw6fbiqBUfB_iK2v47zp2hZ9AGUcVYUK-FsZyACwA",
      "nbf": 1708914993,
      "use": "sig",
      "crv": "P-256",
      "kid": "verifier-backend.eudiw.dev",
      "x5c": [
        "MIIDKjCCArCgAwIBAgIUfy9u6SLtgNuf9PXYbh/QDquXz50wCgYIKoZIzj0EAwIwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMB4XDTI0MDIyNjAyMzYzM1oXDTI2MDIyNTAyMzYzMlowaTEdMBsGA1UEAwwURVVESSBSZW1vdGUgVmVyaWZpZXIxDDAKBgNVBAUTAzAwMTEtMCsGA1UECgwkRVVESSBXYWxsZXQgUmVmZXJlbmNlIEltcGxlbWVudGF0aW9uMQswCQYDVQQGEwJVVDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABMbWBAC1Gj+GDO/yCSbgbFwpivPYWLzEvILNtdCv7Tx1EsxPCxBp3DZB4FIr4BlmVYtGaUboVIihRBiQDo3MpWijggFBMIIBPTAMBgNVHRMBAf8EAjAAMB8GA1UdIwQYMBaAFLNsuJEXHNekGmYxh0Lhi8BAzJUbMCUGA1UdEQQeMByCGnZlcmlmaWVyLWJhY2tlbmQuZXVkaXcuZGV2MBIGA1UdJQQLMAkGByiBjF0FAQYwQwYDVR0fBDwwOjA4oDagNIYyaHR0cHM6Ly9wcmVwcm9kLnBraS5ldWRpdy5kZXYvY3JsL3BpZF9DQV9VVF8wMS5jcmwwHQYDVR0OBBYEFFgmAguBSvSnm68Zzo5IStIv2fM2MA4GA1UdDwEB/wQEAwIHgDBdBgNVHRIEVjBUhlJodHRwczovL2dpdGh1Yi5jb20vZXUtZGlnaXRhbC1pZGVudGl0eS13YWxsZXQvYXJjaGl0ZWN0dXJlLWFuZC1yZWZlcmVuY2UtZnJhbWV3b3JrMAoGCCqGSM49BAMCA2gAMGUCMQDGfgLKnbKhiOVF3xSU0aeju/neGQUVuNbsQw0LeDDwIW+rLatebRgo9hMXDc3wrlUCMAIZyJ7lRRVeyMr3wjqkBF2l9Yb0wOQpsnZBAVUAPyI5xhWX2SAazom2JjsN/aKAkQ==",
        "MIIDHTCCAqOgAwIBAgIUVqjgtJqf4hUYJkqdYzi+0xwhwFYwCgYIKoZIzj0EAwMwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMB4XDTIzMDkwMTE4MzQxN1oXDTMyMTEyNzE4MzQxNlowXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAxMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEFg5Shfsxp5R/UFIEKS3L27dwnFhnjSgUh2btKOQEnfb3doyeqMAvBtUMlClhsF3uefKinCw08NB31rwC+dtj6X/LE3n2C9jROIUN8PrnlLS5Qs4Rs4ZU5OIgztoaO8G9o4IBJDCCASAwEgYDVR0TAQH/BAgwBgEB/wIBADAfBgNVHSMEGDAWgBSzbLiRFxzXpBpmMYdC4YvAQMyVGzAWBgNVHSUBAf8EDDAKBggrgQICAAABBzBDBgNVHR8EPDA6MDigNqA0hjJodHRwczovL3ByZXByb2QucGtpLmV1ZGl3LmRldi9jcmwvcGlkX0NBX1VUXzAxLmNybDAdBgNVHQ4EFgQUs2y4kRcc16QaZjGHQuGLwEDMlRswDgYDVR0PAQH/BAQDAgEGMF0GA1UdEgRWMFSGUmh0dHBzOi8vZ2l0aHViLmNvbS9ldS1kaWdpdGFsLWlkZW50aXR5LXdhbGxldC9hcmNoaXRlY3R1cmUtYW5kLXJlZmVyZW5jZS1mcmFtZXdvcmswCgYIKoZIzj0EAwMDaAAwZQIwaXUA3j++xl/tdD76tXEWCikfM1CaRz4vzBC7NS0wCdItKiz6HZeV8EPtNCnsfKpNAjEAqrdeKDnr5Kwf8BA7tATehxNlOV4Hnc10XO1XULtigCwb49RpkqlS2Hul+DpqObUs"
      ],
      "x": "xtYEALUaP4YM7_IJJuBsXCmK89hYvMS8gs210K_tPHU",
      "y": "EsxPCxBp3DZB4FIr4BlmVYtGaUboVIihRBiQDo3MpWg",
      "exp": 1771986992
    }
  ]
}
"""
  
  static var webKeySet: WebKeySet = try! .init(webKeyJson)
  
  static var validByReferenceWebKeyUrl: URL {
    return URL(string: "https://verifier-backend.eudiw.dev/wallet/public-keys.json")!
  }
  
  static var validByReferenceWebKeyUrlString: String {
    return "https://verifier-backend.eudiw.dev/wallet/public-keys.json"
  }
  
  static var presentationDefinition = PresentationDefinition(
    id: UUID().uuidString,
    inputDescriptors: [
      .init(
        id: "cred1",
        name: nil,
        purpose: nil,
        formatContainer: nil,
        constraints: .init(fields: []),
        groups: nil
      ),
      .init(
        id: "cred2",
        name: nil,
        purpose: nil,
        formatContainer: nil,
        constraints: .init(fields: []),
        groups: nil
      )
    ]
  )
  
  static var signedResponseAlg = "RS256"
  static var encryptedResponseAlg = "RSA-OAEP-256"
  static var encryptedResponseEnc = "A128CBC-HS256"
  static var subjectSyntaxTypesSupported = "urn:ietf:params:oauth:jwk-thumbprint"
  
  static var localHost = "http://localhost:8080"
  static var remoteHost = "https://\(Self.testClientId)"
  static var host = Self.remoteHost
  
  static var certCbor = "o2d2ZXJzaW9uYzEuMGlkb2N1bWVudHOBo2dkb2NUeXBleBhldS5ldXJvcGEuZWMuZXVkaXcucGlkLjFsaXNzdWVyU2lnbmVkompuYW1lU3BhY2VzoXgYZXUuZXVyb3BhLmVjLmV1ZGl3LnBpZC4xmB3YGFhZpGhkaWdlc3RJRBghZnJhbmRvbVC3GZQ4Vaowh4KULM5o7dhhcWVsZW1lbnRJZGVudGlmaWVya2ZhbWlseV9uYW1lbGVsZW1lbnRWYWx1ZWlBTkRFUlNTT07YGFhRpGhkaWdlc3RJRA1mcmFuZG9tUL-V-LtKk1Tnb2BD-75yb2dxZWxlbWVudElkZW50aWZpZXJqZ2l2ZW5fbmFtZWxlbGVtZW50VmFsdWVjSkFO2BhYW6RoZGlnZXN0SUQMZnJhbmRvbVDEd6i_vCHSwwUh0cYis_2EcWVsZW1lbnRJZGVudGlmaWVyamJpcnRoX2RhdGVsZWxlbWVudFZhbHVl2QPsajE5ODUtMDMtMzDYGFhPpGhkaWdlc3RJRAZmcmFuZG9tUC9Iodu5b6Z6RBIlCTasrgJxZWxlbWVudElkZW50aWZpZXJrYWdlX292ZXJfMThsZWxlbWVudFZhbHVl9dgYWFKkaGRpZ2VzdElEGCBmcmFuZG9tUOA2yxnnNGnBHl_-8Mnn_LZxZWxlbWVudElkZW50aWZpZXJsYWdlX2luX3llYXJzbGVsZW1lbnRWYWx1ZRgm2BhYVKRoZGlnZXN0SUQEZnJhbmRvbVD5ahR3sjQQA7vJvAmxHVwhcWVsZW1lbnRJZGVudGlmaWVybmFnZV9iaXJ0aF95ZWFybGVsZW1lbnRWYWx1ZRkHwdgYWFikaGRpZ2VzdElEGBtmcmFuZG9tUGvvcr45W1M-TOXWhqRtGGVxZWxlbWVudElkZW50aWZpZXJpdW5pcXVlX2lkbGVsZW1lbnRWYWx1ZWowMTI4MTk2NTMy2BhYXqRoZGlnZXN0SUQPZnJhbmRvbVCdK4qRNr7JWc2xdOA0bzjvcWVsZW1lbnRJZGVudGlmaWVycWZhbWlseV9uYW1lX2JpcnRobGVsZW1lbnRWYWx1ZWlBTkRFUlNTT07YGFhXpGhkaWdlc3RJRBdmcmFuZG9tUNtO_9G4ZlB1FNureyu40FFxZWxlbWVudElkZW50aWZpZXJwZ2l2ZW5fbmFtZV9iaXJ0aGxlbGVtZW50VmFsdWVjSkFO2BhYVaRoZGlnZXN0SUQOZnJhbmRvbVApwjr0dHp75VqkyCojGZkbcWVsZW1lbnRJZGVudGlmaWVya2JpcnRoX3BsYWNlbGVsZW1lbnRWYWx1ZWZTV0VERU7YGFhTpGhkaWdlc3RJRBVmcmFuZG9tUNZ7jedRLHgQ00_WB9umaIxxZWxlbWVudElkZW50aWZpZXJtYmlydGhfY291bnRyeWxlbGVtZW50VmFsdWViU0XYGFhSpGhkaWdlc3RJRBgZZnJhbmRvbVCN_FgslPAt6ncEwX4jv3NicWVsZW1lbnRJZGVudGlmaWVya2JpcnRoX3N0YXRlbGVsZW1lbnRWYWx1ZWJTRdgYWFqkaGRpZ2VzdElEGBhmcmFuZG9tUAlRldKQE3gdvstn8eAE48JxZWxlbWVudElkZW50aWZpZXJqYmlydGhfY2l0eWxlbGVtZW50VmFsdWVrS0FUUklORUhPTE3YGFhkpGhkaWdlc3RJRBgeZnJhbmRvbVCMsClpQzri9Ts3rvrGQyNHcWVsZW1lbnRJZGVudGlmaWVycHJlc2lkZW50X2FkZHJlc3NsZWxlbWVudFZhbHVlb0ZPUlRVTkFHQVRBTiAxNdgYWFakaGRpZ2VzdElEC2ZyYW5kb21QeJHFNssLiRkDK8XFJFGuQHFlbGVtZW50SWRlbnRpZmllcnByZXNpZGVudF9jb3VudHJ5bGVsZW1lbnRWYWx1ZWJTRdgYWFWkaGRpZ2VzdElEGBpmcmFuZG9tUFf3D57jOLFNyMGkPOeq439xZWxlbWVudElkZW50aWZpZXJucmVzaWRlbnRfc3RhdGVsZWxlbWVudFZhbHVlYlNF2BhYXKRoZGlnZXN0SUQTZnJhbmRvbVBWB0GNrKdBQVrlpImIRgUUcWVsZW1lbnRJZGVudGlmaWVybXJlc2lkZW50X2NpdHlsZWxlbWVudFZhbHVla0tBVFJJTkVIT0xN2BhYXaRoZGlnZXN0SUQSZnJhbmRvbVDsZlLl2N7J71jX-6bXsnwEcWVsZW1lbnRJZGVudGlmaWVydHJlc2lkZW50X3Bvc3RhbF9jb2RlbGVsZW1lbnRWYWx1ZWU2NDEzM9gYWF-kaGRpZ2VzdElEAGZyYW5kb21QeVoB8I5BSgsvMvSFktXxSXFlbGVtZW50SWRlbnRpZmllcm9yZXNpZGVudF9zdHJlZXRsZWxlbWVudFZhbHVlbEZPUlRVTkFHQVRBTtgYWFykaGRpZ2VzdElEGB1mcmFuZG9tUPZqEH9sCb0LsU7Q1r6NY9pxZWxlbWVudElkZW50aWZpZXJ1cmVzaWRlbnRfaG91c2VfbnVtYmVybGVsZW1lbnRWYWx1ZWIxMtgYWEukaGRpZ2VzdElEGBxmcmFuZG9tUECs5kRT8jGbvlJFfN9PzHVxZWxlbWVudElkZW50aWZpZXJmZ2VuZGVybGVsZW1lbnRWYWx1ZQHYGFhRpGhkaWdlc3RJRBRmcmFuZG9tUJAnJk_8qaLhZyz16KD1mm5xZWxlbWVudElkZW50aWZpZXJrbmF0aW9uYWxpdHlsZWxlbWVudFZhbHVlYlNF2BhYZqRoZGlnZXN0SUQQZnJhbmRvbVDnNyg3BVSwxg7oPIz_ex1lcWVsZW1lbnRJZGVudGlmaWVybWlzc3VhbmNlX2RhdGVsZWxlbWVudFZhbHVlwHQyMDA5LTAxLTAxVDAwOjAwOjAwWtgYWGSkaGRpZ2VzdElEEWZyYW5kb21QiLdvkB7-ePM8bQhtrw03P3FlbGVtZW50SWRlbnRpZmllcmtleHBpcnlfZGF0ZWxlbGVtZW50VmFsdWXAdDIwNTAtMDMtMzBUMDA6MDA6MDBa2BhYWaRoZGlnZXN0SUQYH2ZyYW5kb21Q88ycru5RpECbD5sO1xF5JXFlbGVtZW50SWRlbnRpZmllcnFpc3N1aW5nX2F1dGhvcml0eWxlbGVtZW50VmFsdWVjVVRP2BhYXKRoZGlnZXN0SUQHZnJhbmRvbVD5ok_CSVzYG_zxW4dCLYgRcWVsZW1lbnRJZGVudGlmaWVyb2RvY3VtZW50X251bWJlcmxlbGVtZW50VmFsdWVpMTExMTExMTE02BhYY6RoZGlnZXN0SUQWZnJhbmRvbVADONLlWKTDtc-PYFNRXifWcWVsZW1lbnRJZGVudGlmaWVydWFkbWluaXN0cmF0aXZlX251bWJlcmxlbGVtZW50VmFsdWVqOTAxMDE2NzQ2NNgYWFWkaGRpZ2VzdElEAWZyYW5kb21QnEwHop2wmETQk18jh7jsMnFlbGVtZW50SWRlbnRpZmllcm9pc3N1aW5nX2NvdW50cnlsZWxlbWVudFZhbHVlYlNF2BhYXKRoZGlnZXN0SUQJZnJhbmRvbVCakKMOPVNIi1XdtiS3RAEGcWVsZW1lbnRJZGVudGlmaWVydGlzc3VpbmdfanVyaXNkaWN0aW9ubGVsZW1lbnRWYWx1ZWRTRS1Jamlzc3VlckF1dGiEQ6EBJqEYIVkChTCCAoEwggImoAMCAQICCRZK5ZkC3AUQZDAKBggqhkjOPQQDAjBYMQswCQYDVQQGEwJCRTEcMBoGA1UEChMTRXVyb3BlYW4gQ29tbWlzc2lvbjErMCkGA1UEAxMiRVUgRGlnaXRhbCBJZGVudGl0eSBXYWxsZXQgVGVzdCBDQTAeFw0yMzA1MzAxMjMwMDBaFw0yNDA1MjkxMjMwMDBaMGUxCzAJBgNVBAYTAkJFMRwwGgYDVQQKExNFdXJvcGVhbiBDb21taXNzaW9uMTgwNgYDVQQDEy9FVSBEaWdpdGFsIElkZW50aXR5IFdhbGxldCBUZXN0IERvY3VtZW50IFNpZ25lcjBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABHyTE_TBpKpOsLPraBGkmU5Z3meZZDHC864IjrehBhy2WL2MORJsGVl6yQ35nQeNPvORO6NL2yy8aYfQJ-mvnfyjgcswgcgwHQYDVR0OBBYEFNGksSQ5MvtFcnKZSPJSfZVYp00tMB8GA1UdIwQYMBaAFDKR6w4cAR0UDnZPbE_qTJY42vsEMA4GA1UdDwEB_wQEAwIHgDASBgNVHSUECzAJBgcogYxdBQECMB8GA1UdEgQYMBaGFGh0dHA6Ly93d3cuZXVkaXcuZGV2MEEGA1UdHwQ6MDgwNqA0oDKGMGh0dHBzOi8vc3RhdGljLmV1ZGl3LmRldi9wa2kvY3JsL2lzbzE4MDEzLWRzLmNybDAKBggqhkjOPQQDAgNJADBGAiEA3l-Y5x72V1ISa_LEuE_e34HSQ8pXsVvTGKq58evrP30CIQD-Ivcya0tXWP8W_obTOo2NKYghadoEm1peLIBqsUcISFkF9tgYWQXxpmd2ZXJzaW9uYzEuMG9kaWdlc3RBbGdvcml0aG1nU0hBLTI1Nmdkb2NUeXBleBhldS5ldXJvcGEuZWMuZXVkaXcucGlkLjFsdmFsdWVEaWdlc3RzoXgYZXUuZXVyb3BhLmVjLmV1ZGl3LnBpZC4xuCIAWCD7W3-dBVCt3o3cDIYNaDkM1DS45diRQiz4K3YWFeSWFQFYIKJtyxTxqSQabkLeNzlU47KF9EGDkj3V5rH0e9Q1-lsEAlggUNP1_0Zc8kTYS8QL6z4oQomUBgH6O-shAj5iyZ8bCAUDWCCuQigYwxLYp4LVGOTGUs1qnnTU1tvLMcC98b_VigL_swRYIAfS34ulNQZvT0E22diN-NuIae52N9SzZXe-xlMp5C1vBVggAkEv95LMRoGJyOteiPfAU8_PThHsdmzt0Xyt6JoEsZoGWCDXqUDv-8ZAiWDnaafykV_T_01Lp1riTPapZNU5zI40wgdYIFLiTVYD7-VcrqniT04k_Q5H-hN6tYOEhk9hsTo11doKCFggxZXKN--iXILeaopizcn63992DEtS0KUxuEY6G7tSqB0JWCA7b-nAaWHc3AjTMtCTo178-Fq1bUrtCL39os-grqpa7QpYIIiHGCd2RZ3WPvhk7IIs-dxoWlc1v8SStjYi7uIzo__2C1ggmJ0y-WZefrnjeKUSoJgp48nLSgUGpKTllcz75lcj8TwMWCAteXytlADF9YQcRhXnbHZ4hU-3Fn5V-Yfbmo4A04Cq0Q1YIMQKhcyPGZizCKvulDn8dUumLukLSmAqeno7xdvBPYlQDlggh5HapQ08xo6J5hPpvxtKamGU5Q2yNAc_dwLuyZ9vZ7UPWCBquMRplGPA8YtUtWPsWswGMb-G8N9ZDVBEtMU96CJN0hBYIJLyfEQ3cYpDg7P6qDlmAO0zG7uQB_RVzHsPRXOtJZrTEVggJujmxDXHoF1vp6Os2d_7Y5lyuo0JVrxd78aAU8OnLOgSWCA-9Wlkv2ooawcektfcHHta08eB06bKB5ckORg3_6Gt6RNYIOrbnoAvuGPILZb4oU9OXuFwhrmN24sUHQHaJM1wPo6CFFgg-YDc24tVJZ1aBiVZrIryUkklnztL_DjkSW_0qLuDjsUVWCAxr4Uys8fXbxeTvKfofNqpxTmo7mwCTygExduL5M38MBZYIJXXKk1Az7gaKrhY_Ahsz_n8pDhDY1Lfmqm0QS4JoaF8F1ggl-1ikQmy375eg5ya4CmO4iUZRb7iWm1zeI6zhUhM7lEYGFggMJUtUrlwL9MPNFtEb0Hnz5SqB2qlQrrQj3ZnQM-mGmgYGVggWl3f3p6lfBFnbu2daWLJm39SoGElzlfavTOx3F_3E74YGlggvdD45pF51Cy3yiZ2_nSYqVqJyHT8QNToZG6TNzWEwHAYG1gg8ANMye6A3IzWp2c8WNSRM0Y2Mh1mjIRPw0HKx3isb5gYHFggNDf7Ax-w_4phWXsVvPRk7P7ofgHjKkUBT78O75cwXIkYHVggDXc6YZNFdRk46rqUsKlvVmMzpBHnqA2XZJmqaugJvzcYHlggXH0jeH3-U3jTzR37HDW-jWK6ouF-G5NNPuJmuj6hpQEYH1ggG0an4SprpVwTUMcScwaAZg0Le3EUMRXs2kXZEMi1YiMYIFggI1FLAHl0o8wOVSfw9YJXN8sMeV9UlVg6hpK5ftfTO7EYIVggplIunh7mRw7jAxRznT1H65zgNia37L_reyAW-NqDRPBtZGV2aWNlS2V5SW5mb6FpZGV2aWNlS2V5pAECIAEhWCABzyHIg6bpG-9oGY8eJKRliIpIZAkYu6kgXPmqWEat-yJYIINkaU-HyQEVbtaFN1tc2jlxpe-HF1qvKIpq_oZyZ9gtbHZhbGlkaXR5SW5mb6Nmc2lnbmVkwHQyMDIzLTA5LTA1VDEyOjIyOjUwWml2YWxpZEZyb23AdDIwMjMtMDktMDVUMTI6MjI6NTBaanZhbGlkVW50aWzAdDIwMjQtMDktMDVUMTI6MjI6NTBaWEBrha1cC82HzHS162luGdghMM6OKLzqSaFZk_n1sxiHVkt3Hg9p8N5nE0lHUeUSoGTPzxfLRy-iX98Hd2YRSoybbGRldmljZVNpZ25lZKJqbmFtZVNwYWNlc9gYQaBqZGV2aWNlQXV0aKFvZGV2aWNlU2lnbmF0dXJlhEOhASag9lhA2m2BqQWbJmPL5xogKMm0Vw7_kakFqEStS3nGjaWZmTXmUzuVTLNw8pHw-0rcgd4oPIwpFwHyFYcS5AFaDLujPmZzdGF0dXMA"
  
  static var cbor = "o2d2ZXJzaW9uYzEuMGlkb2N1bWVudHOCo2dkb2NUeXBld2V1LmV1cm9wYS5lYy5ldWRpLnBpZC4xbGlzc3VlclNpZ25lZKJqbmFtZVNwYWNlc6F3ZXUuZXVyb3BhLmVjLmV1ZGkucGlkLjGB2BhYU6RoZGlnZXN0SUQBZnJhbmRvbVDLOKt7d-Qv5sfsfZLl6ZY_cWVsZW1lbnRJZGVudGlmaWVya2ZhbWlseV9uYW1lbGVsZW1lbnRWYWx1ZWROZWFsamlzc3VlckF1dGiEQ6EBJqEYIVkDMTCCAy0wggKyoAMCAQICFC_LOU7Ot-ZOjoa0RTJbEkQEmKOmMAoGCCqGSM49BAMCMFwxHjAcBgNVBAMMFVBJRCBJc3N1ZXIgQ0EgLSBVVCAwMTEtMCsGA1UECgwkRVVESSBXYWxsZXQgUmVmZXJlbmNlIEltcGxlbWVudGF0aW9uMQswCQYDVQQGEwJVVDAeFw0yNDExMjkxMTI4MzVaFw0yNjExMjkxMTI4MzRaMGkxHTAbBgNVBAMMFEVVREkgUmVtb3RlIFZlcmlmaWVyMQwwCgYDVQQFEwMwMDExLTArBgNVBAoMJEVVREkgV2FsbGV0IFJlZmVyZW5jZSBJbXBsZW1lbnRhdGlvbjELMAkGA1UEBhMCVVQwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQFmvVGq-6D9WWxhW7BQOIN9T8zRmXMIdr0ezwpJNGIgC-HIa7JYPXI9ZAcp8mYu52a2IDzie8dGrURXZMX147Qo4IBQzCCAT8wDAYDVR0TAQH_BAIwADAfBgNVHSMEGDAWgBSzbLiRFxzXpBpmMYdC4YvAQMyVGzAnBgNVHREEIDAeghxkZXYuaXNzdWVyLWJhY2tlbmQuZXVkaXcuZGV2MBIGA1UdJQQLMAkGByiBjF0FAQYwQwYDVR0fBDwwOjA4oDagNIYyaHR0cHM6Ly9wcmVwcm9kLnBraS5ldWRpdy5kZXYvY3JsL3BpZF9DQV9VVF8wMS5jcmwwHQYDVR0OBBYEFPHhwPzF75MgheENYqLlz9LKYjFIMA4GA1UdDwEB_wQEAwIHgDBdBgNVHRIEVjBUhlJodHRwczovL2dpdGh1Yi5jb20vZXUtZGlnaXRhbC1pZGVudGl0eS13YWxsZXQvYXJjaGl0ZWN0dXJlLWFuZC1yZWZlcmVuY2UtZnJhbWV3b3JrMAoGCCqGSM49BAMCA2kAMGYCMQCYykgNwO5GDgWMCQjjnK3GkQg3lU33L2GAkfAI8p1ItuSP7ZLAwhQOfpmgi35pFCkCMQDlYxrIJbkMEzedKPe1popR25VuDfPqgK5rAQvI0yLrZyn3OMmd7uUNbmWCJW7Skq5ZBM_YGFkEyqZndmVyc2lvbmMxLjBvZGlnZXN0QWxnb3JpdGhtZ1NIQS0yNTZsdmFsdWVEaWdlc3RzoXdldS5ldXJvcGEuZWMuZXVkaS5waWQuMbgZAFggOhcWGq5FFshUpShyf_v7d8LYVx6hQCdnxqhpPYHXptEBWCBhxi-7MIUyIEf9eXsmtpb6bS3WMlvb1IKVfJDGL-E3cAJYICXP8ZyU3U_4e51NAohWDbqmeGabjj93_FA6Q7_KxPKwA1ggHEMoLXvCT6RW1CVMeMU47-rwRMj7wVjbJ0_UBQ_sZ-wEWCDT9-SwKjha0nna10diAO9IxPB46svGBKkNiXAR77IdyAVYIMjjf2tii5ocW3XHKUmvtaIje4jpQz0AuL7Twe33abktBlggKhhf9sCpvmndwAAKW4umOxWkLtz4Kyv1h5zcAEwNUvAHWCDp6NsFQJmpb9Jatz_dBayRv14x2Qffl4AxCOzRouFWsQhYIEOC_EaY5ww8qW60NZ_cYfn40xgFSZKjxzReZuqxWMx8CVggHuln1oLn-ZOufRheOmtSHxAxl4acTxZ52w2_QbUYiFgKWCB9i5tS8oKFUb55BroSRVPs1siu1VH5XVV-kt1vUGlhAAtYIB0ta7Hoc4HGgDVL-cLCo7wJ-fOzaXTsfaLc5V56a0GsDFggHSDNQdsvGKwx4pvXJ9zVcwlbUds_6uSwNKiRqBa-QgENWCCA18f0ek8765otJdOkDu-NhvxuKVaRG9YZKPpjARSyWA5YIOzd-VzaPIJPnJTEgkl13Wx8vaZ0JN2roUyyXxQJ19dBD1ggo7HAuf1bjEPAvB_QsPoNGk82qUxifiYfc-clTFQGjs4QWCCV9sgpz0Pwiu9tGxApqWyDc1LtD_Fu5AZ4Gk4Al0TQDhFYIBirH7jbqqpXrh4r0kzLEeut0u8wkIpanFk0TzliVmwnElggTpMBOhEWHDOMUXV2DTBDYtUIcO5j94bZAxZIFfWNsGMTWCCtRqkcGgnf-L4qexXf_bS2I32qfG_tCTUaSSjLBkQibxRYIPrvcdGkjj7uH31FoWjM4aoo7mCwH6TD2FklUg-GfRbtFVgglAIC8TTTc6JW5azcNzrm3DTujvKvb1fT2bOfMnC0ZasWWCAn1cdYJ8UFyYHiG5ZhdJkntNNrtS5ZVSdLfqKZo866QBdYIP3SPKdiReOR5XVI3mP-JIekpQQTFHVCJmhMr8JAuFhcGBhYIIz9kkhORpqu7260xaPkzHBm-T92zcYOcWA0yjGhYU3JbWRldmljZUtleUluZm-haWRldmljZUtleaQBAiABIVggJ0AUWqVTHQCZLfZ9l6etiocOFUDMiwOA9NdRMlnEdNUiWCDQqWiJYDFx5WrF3iWOF_eyDwMlb2lwwbr8vJH9QsEtpmdkb2NUeXBld2V1LmV1cm9wYS5lYy5ldWRpLnBpZC4xbHZhbGlkaXR5SW5mb6Nmc2lnbmVkwHgeMjAyNS0wMi0wN1QxNDoxNDoxNC4yNTQxMzU5MzRaaXZhbGlkRnJvbcB4HjIwMjUtMDItMDdUMTQ6MTQ6MTQuMjU0MTM1OTM0Wmp2YWxpZFVudGlswHgeMjAyNy0wMi0wN1QxNDoxNDoxNC4yNTQxMzU5MzRaWEDTbHm2IyQEZlx3sywuYiw3qICbikVdUtyaHceDdV4qIAQdpOScsTAWTH9GVvh1FiPWE2qdQCTdl8O9_wGQpth3bGRldmljZVNpZ25lZKJqbmFtZVNwYWNlc9gYQaBqZGV2aWNlQXV0aKFvZGV2aWNlU2lnbmF0dXJlhEOhASag9lhA0Cu_ymkje1B5BkBExIvyYCaFQqItzzaB8Mr1UPkSj86gWYjvKRhwmPKDEP0BoxZbwDqdmP0z1Q5BFGfIHLFqaqNnZG9jVHlwZXVvcmcuaXNvLjE4MDEzLjUuMS5tRExsaXNzdWVyU2lnbmVkompuYW1lU3BhY2VzoXFvcmcuaXNvLjE4MDEzLjUuMYHYGFhXpGhkaWdlc3RJRABmcmFuZG9tUG79RwEsn9sSFymhhWnyeqZxZWxlbWVudElkZW50aWZpZXJrZmFtaWx5X25hbWVsZWxlbWVudFZhbHVlaEdlb3JnaW91amlzc3VlckF1dGiEQ6EBJqEYIVkDMTCCAy0wggKyoAMCAQICFC_LOU7Ot-ZOjoa0RTJbEkQEmKOmMAoGCCqGSM49BAMCMFwxHjAcBgNVBAMMFVBJRCBJc3N1ZXIgQ0EgLSBVVCAwMTEtMCsGA1UECgwkRVVESSBXYWxsZXQgUmVmZXJlbmNlIEltcGxlbWVudGF0aW9uMQswCQYDVQQGEwJVVDAeFw0yNDExMjkxMTI4MzVaFw0yNjExMjkxMTI4MzRaMGkxHTAbBgNVBAMMFEVVREkgUmVtb3RlIFZlcmlmaWVyMQwwCgYDVQQFEwMwMDExLTArBgNVBAoMJEVVREkgV2FsbGV0IFJlZmVyZW5jZSBJbXBsZW1lbnRhdGlvbjELMAkGA1UEBhMCVVQwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQFmvVGq-6D9WWxhW7BQOIN9T8zRmXMIdr0ezwpJNGIgC-HIa7JYPXI9ZAcp8mYu52a2IDzie8dGrURXZMX147Qo4IBQzCCAT8wDAYDVR0TAQH_BAIwADAfBgNVHSMEGDAWgBSzbLiRFxzXpBpmMYdC4YvAQMyVGzAnBgNVHREEIDAeghxkZXYuaXNzdWVyLWJhY2tlbmQuZXVkaXcuZGV2MBIGA1UdJQQLMAkGByiBjF0FAQYwQwYDVR0fBDwwOjA4oDagNIYyaHR0cHM6Ly9wcmVwcm9kLnBraS5ldWRpdy5kZXYvY3JsL3BpZF9DQV9VVF8wMS5jcmwwHQYDVR0OBBYEFPHhwPzF75MgheENYqLlz9LKYjFIMA4GA1UdDwEB_wQEAwIHgDBdBgNVHRIEVjBUhlJodHRwczovL2dpdGh1Yi5jb20vZXUtZGlnaXRhbC1pZGVudGl0eS13YWxsZXQvYXJjaGl0ZWN0dXJlLWFuZC1yZWZlcmVuY2UtZnJhbWV3b3JrMAoGCCqGSM49BAMCA2kAMGYCMQCYykgNwO5GDgWMCQjjnK3GkQg3lU33L2GAkfAI8p1ItuSP7ZLAwhQOfpmgi35pFCkCMQDlYxrIJbkMEzedKPe1popR25VuDfPqgK5rAQvI0yLrZyn3OMmd7uUNbmWCJW7Skq5ZBOvYGFkE5qZndmVyc2lvbmMxLjBvZGlnZXN0QWxnb3JpdGhtZ1NIQS0yNTZsdmFsdWVEaWdlc3RzoXFvcmcuaXNvLjE4MDEzLjUuMbgaAFggMB0uLEYoIneUL0kereEYCwIDPhFlzG8CRz8mhaOAjqYBWCDeL02NKHTFMnNnvQhiCvqpTol-KZsWotcrp0qQZX5d5QJYIEe49kmpXoF28fhJp_mmyvaJ9_DWptgciOwNDLjvGG3vA1ggwS9c7Pgo_bVTGX6_kKL6b_S_XdFpJeZrNPIzztOfIiYEWCAewkcL6ERlKhMrKfRcIc6kk4686GEw9391vK-1DqC3OAVYICjzEaK6wNF3xg2ihweQATbQe3NWUevjQJA6UE7qgKxBBlgg3HBSVgWY5xeur7rNraq3xyiL9nUWMGU5aOJsSc8tspcHWCAb4P2vyc0Y5AaqLTtupspXYNYOadmK6xPBSlf9CTB6DQhYIIi6l_O69bNVfXPwXmyTIDNGgWUCgasiNr3Py4vtd8lgCVggm_9UfaiuFMpyG5Wk25RMt_NRsRyo_hX1NR1PqzTMeeEKWCCGP-XEprUyt6azpavKitGk-A1uv3_SrJuXqm4MAlZHvAtYIHdyYg5YZxq_Zu5g7ERaw3LytEpihtNT_oXk2eKXsNXBDFgg_5GNWEZH0tJQ_Yd12HuMQCKg0cx2KthoMznsTj3wxeUNWCBU8driwLnS1IB97lWGJ2J79P-tg8FjIZ5CvFIBJ6FACg5YIIIJZd7HfHi06lFp0IbKCcrsVz86mIt39RxTR-603zCgD1ggE20AVA9nIp5-ttQ9i6CU8UD3U3GrH-L-FNoYSlZ_j_0QWCAy6d3Q8GMFj_I_m2KLaw-X-S4eMRBmE7O2Ou_J_H09mxFYIGxt_8sVd3BoMRZiu-uBJovSmstMIgFXSM2FaMmXSydnElggxQJZbssCwVYRnv2ZdAa1eNkFdvgalLNfMEhxpTnNiIsTWCB_u8P7WHe8ll2-OxbM2UXLxNNDPJUQaXo4438QLdSunBRYIMcUaKm2dLv44pOSZvwwTw7y1c3pRiLhS0Or4EQp1ozIFVgg2qZd8xExSL5Ypu6JigV2F3IzdAGCqNq109RVDAHpwsUWWCAfpZrVbcpvXhUwrXewy0LMWpWW8ZmbUiGkM8UARkKEMBdYIIRZ3sDbFWF131NYO2ATE3BrFJLY_2cTzk_UrJ9Vm84RGBhYIG29wGNAT-5IBorJLIin3-bgAYOXW6G_fSa2zFh0J1zFGBlYIAummtqcnzwR_AjgluEA9xb8ClHXm7nDFArD_uyNnpkHbWRldmljZUtleUluZm-haWRldmljZUtleaQBAiABIVgglui92FfsuUU1Q0Sq1ZYIrAOxLzzPS4674eae1vRHoRwiWCAJJtjfLV3LGzfmoBLuCw_y3Nv1fmCd_YRby0hzYn8Tnmdkb2NUeXBldW9yZy5pc28uMTgwMTMuNS4xLm1ETGx2YWxpZGl0eUluZm-jZnNpZ25lZMB4HjIwMjUtMDItMDdUMTQ6MTQ6MTQuNTgxNjk3NDM2Wml2YWxpZEZyb23AeB4yMDI1LTAyLTA3VDE0OjE0OjE0LjU4MTY5NzQzNlpqdmFsaWRVbnRpbMB4HjIwMjctMDItMDdUMTQ6MTQ6MTQuNTgxNjk3NDM2WlhAGmdQqmiiBzUJkYj_dUzBwGjjwWMdO_qC_MmEvP-ni6il-VTBkJe2952j87Oa9v-a-HbfTcAKgX7w0BFb46iAs2xkZXZpY2VTaWduZWSiam5hbWVTcGFjZXPYGEGgamRldmljZUF1dGihb2RldmljZVNpZ25hdHVyZYRDoQEmoPZYQOsoPictwMbFLFsbHRyS7GnPn9nHYogN-xkLYjJv0DGs0YU7LhAHRpqLGFe1ira5MD7ryABhUSUeoNth94vr3W1mc3RhdHVzAA"
  
  static var x5cCertificate = "MIIDSTCCAjGgAwIBAgIUBAfbyjpjLFsSTAaCY43xSz/aKB8wDQYJKoZIhvcNAQELBQAwFjEUMBIGA1UEAwwLZXhhbXBsZS5jb20wHhcNMjQwMTEwMTQzNTQyWhcNMjUwMTA5MTQzNTQyWjAWMRQwEgYDVQQDDAtleGFtcGxlLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK6JArDMWQH+JImQW4Kdlzt25obTlUzmXQBMHVZ47M5VgPBAQ25Db8y7ev7CVV7WFTxNrISLER0tVW47I7H4mzfbcK1UCEyRA6A1uwbfdw1af4ajOuVqoWqJFB2zqK3VmjymqWAvSPfnXR1UyMQQj2NObABz4YacuuK3uzcOKnmHYQ8adavzvPLmeA06s9Hjk6RjEoCazAngYABdA3bVfi6TS0Nqj4B5580BVu5HFTj8Pw7aDBVQ6tj/uBgJW4tKQlARn3aMGJbZ1zUC2pFyJ8bMQnejqmuD4mJpmPf+Ihz4nQlYTFKFlK3ASRZjfgDd3rkktPu8CQ9Sg1bTaZWOw1UCAwEAAaOBjjCBizBqBgNVHREEYzBhggtleGFtcGxlLmNvbYIVc3ViZG9tYWluLmV4YW1wbGUuY29tghxjbGllbnRfaWRlbnRpZmVyLmV4YW1wbGUuY29thwTAqAEBhhdodHRwczovL3d3dy5leGFtcGxlLmNvbTAdBgNVHQ4EFgQUEkq36yycm2K2uF1lYCOZDwHmFmIwDQYJKoZIhvcNAQELBQADggEBAIz/fqjYX6iFYqJyJVESoXuLigceG/mGz2mOnXnA5EDjZqk+0rwngMA4So8cHSUcD31UNmG26zWrPM1gFVkjZNn5gcpxdRkYzONDbBNFKoHBxUJIRvDuR3JpesI7aBmYWr3gm68EYa2CUyUztW7hIc7KAao85UI5Q49o9cJxT6EjwDXz8NsJS6lHCDEP7R0ZBjI1Qnv8BIzZKsLoPMt5LxUCVpoV+MjrcKIBTsoISJpI4SAYG/Yz1YWlhSD1rYNax1V21EeN9T+E111JqVve2AQMr3CLLtMAiY5jPIXlFvtiIUtY9I3uGdd2QA/HNiE87Q6o07wf8n/groYy2fVONYo="
  
  static var x5cRootCertificate = "MIIDdzCCAl+gAwIBAgIEAgAAuTANBgkqhkiG9w0BAQUFADBaMQswCQYDVQQGEwJJRTESMBAGA1UEChMJQmFsdGltb3JlMRMwEQYDVQQLEwpDeWJlclRydXN0MSIwIAYDVQQDExlCYWx0aW1vcmUgQ3liZXJUcnVzdCBSb290MB4XDTAwMDUxMjE4NDYwMFoXDTI1MDUxMjIzNTkwMFowWjELMAkGA1UEBhMCSUUxEjAQBgNVBAoTCUJhbHRpbW9yZTETMBEGA1UECxMKQ3liZXJUcnVzdDEiMCAGA1UEAxMZQmFsdGltb3JlIEN5YmVyVHJ1c3QgUm9vdDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKMEuyKrmD1X6CZymrV51Cni4eiVgLGw41uOKymaZN+hXe2wCQVt2yguzmKiYv60iNoS6zjrIZ3AQSsBUnuId9Mcj8e6uYi1agnnc+gRQKfRzMpijS3ljwumUNKoUMMo6vWrJYeKmpYcqWe4PwzV9/lSEy/CG9VwcPCPwBLKBsua4dnKM3p31vjsufFoREJIE9LAwqSuXmD+tqYF/LTdB1kC1FkYmGP1pWPgkAx9XbIGevOF6uvUA65ehD5f/xXtabz5OTZydc93Uk3zyZAsuT3lySNTPx8kmCFcB5kpvcY67Oduhjprl3RjM71oGDHweI12v/yejl0qhqdNkNwnGjkCAwEAAaNFMEMwHQYDVR0OBBYEFOWdWTCCR1jMrPoIVDaGezq1BE3wMBIGA1UdEwEB/wQIMAYBAf8CAQMwDgYDVR0PAQH/BAQDAgEGMA0GCSqGSIb3DQEBBQUAA4IBAQCFDF2O5G9RaEIFoN27TyclhAO992T9Ldcw46QQF+vaKSm2eT929hkTI7gQCvlYpNRhcL0EYWoSihfVCr3FvDB81ukMJY2GQE/szKN+OMY3EU/t3WgxjkzSswF07r51XgdIGn9w/xZchMB5hbgF/X++ZRGjD8ACtPhSNzkE1akxehi/oCr0Epn3o0WC4zxe9Z2etciefC7IpJ5OCBRLbf1wbWsaY71k5h+3zvDyny67G7fyUIhzksLi4xaNmjICq44Y3ekQEe5+NauQrz4wlHrQMz2nZQ/1/I6eYs9HRCwBXbsdtTLSR9I4LtD+gdwyah617jzV/OeBHRnDJELqYzmp"
  
  static var x5cRootCertificateBase64 = "TUlJRGR6Q0NBbCtnQXdJQkFnSUVBZ0FBdVRBTkJna3Foa2lHOXcwQkFRVUZBREJhTVFzd0NRWURWUVFHRXdKSlJURVNNQkFHQTFVRUNoTUpRbUZzZEdsdGIzSmxNUk13RVFZRFZRUUxFd3BEZVdKbGNsUnlkWE4wTVNJd0lBWURWUVFERXhsQ1lXeDBhVzF2Y21VZ1EzbGlaWEpVY25WemRDQlNiMjkwTUI0WERUQXdNRFV4TWpFNE5EWXdNRm9YRFRJMU1EVXhNakl6TlRrd01Gb3dXakVMTUFrR0ExVUVCaE1DU1VVeEVqQVFCZ05WQkFvVENVSmhiSFJwYlc5eVpURVRNQkVHQTFVRUN4TUtRM2xpWlhKVWNuVnpkREVpTUNBR0ExVUVBeE1aUW1Gc2RHbHRiM0psSUVONVltVnlWSEoxYzNRZ1VtOXZkRENDQVNJd0RRWUpLb1pJaHZjTkFRRUJCUUFEZ2dFUEFEQ0NBUW9DZ2dFQkFLTUV1eUtybUQxWDZDWnltclY1MUNuaTRlaVZnTEd3NDF1T0t5bWFaTitoWGUyd0NRVnQyeWd1em1LaVl2NjBpTm9TNnpqcklaM0FRU3NCVW51SWQ5TWNqOGU2dVlpMWFnbm5jK2dSUUtmUnpNcGlqUzNsand1bVVOS29VTU1vNnZXckpZZUttcFljcVdlNFB3elY5L2xTRXkvQ0c5VndjUENQd0JMS0JzdWE0ZG5LTTNwMzF2anN1ZkZvUkVKSUU5TEF3cVN1WG1EK3RxWUYvTFRkQjFrQzFGa1ltR1AxcFdQZ2tBeDlYYklHZXZPRjZ1dlVBNjVlaEQ1Zi94WHRhYno1T1RaeWRjOTNVazN6eVpBc3VUM2x5U05UUHg4a21DRmNCNWtwdmNZNjdPZHVoanBybDNSak03MW9HREh3ZUkxMnYveWVqbDBxaHFkTmtOd25HamtDQXdFQUFhTkZNRU13SFFZRFZSME9CQllFRk9XZFdUQ0NSMWpNclBvSVZEYUdlenExQkUzd01CSUdBMVVkRXdFQi93UUlNQVlCQWY4Q0FRTXdEZ1lEVlIwUEFRSC9CQVFEQWdFR01BMEdDU3FHU0liM0RRRUJCUVVBQTRJQkFRQ0ZERjJPNUc5UmFFSUZvTjI3VHljbGhBTzk5MlQ5TGRjdzQ2UVFGK3ZhS1NtMmVUOTI5aGtUSTdnUUN2bFlwTlJoY0wwRVlXb1NpaGZWQ3IzRnZEQjgxdWtNSlkyR1FFL3N6S04rT01ZM0VVL3QzV2d4amt6U3N3RjA3cjUxWGdkSUduOXcveFpjaE1CNWhiZ0YvWCsrWlJHakQ4QUN0UGhTTnprRTFha3hlaGkvb0NyMEVwbjNvMFdDNHp4ZTlaMmV0Y2llZkM3SXBKNU9DQlJMYmYxd2JXc2FZNzFrNWgrM3p2RHlueTY3RzdmeVVJaHprc0xpNHhhTm1qSUNxNDRZM2VrUUVlNStOYXVRcno0d2xIclFNejJuWlEvMS9JNmVZczlIUkN3Qlhic2R0VExTUjlJNEx0RCtnZHd5YWg2MTdqelYvT2VCSFJuREpFTHFZem1w"
  
  static var x5cLeafCertificate = "MIIFDTCCBLSgAwIBAgIQDfGp1LldLaZknAqfNm6mjjAKBggqhkjOPQQDAjBKMQswCQYDVQQGEwJVUzEZMBcGA1UEChMQQ2xvdWRmbGFyZSwgSW5jLjEgMB4GA1UEAxMXQ2xvdWRmbGFyZSBJbmMgRUNDIENBLTMwHhcNMjMxMDI1MDAwMDAwWhcNMjQxMDIzMjM1OTU5WjBvMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMNU2FuIEZyYW5jaXNjbzEZMBcGA1UEChMQQ2xvdWRmbGFyZSwgSW5jLjEYMBYGA1UEAxMPY2hhdC5vcGVuYWkuY29tMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAELYia1YcrVMZDdt21jKAVP00D1hWwJbX3Pd2SERdzLyUqr8CW8p/n9YO2Bdgsszekb1XX7CgWfmZfs08DfDcPMaOCA1UwggNRMB8GA1UdIwQYMBaAFKXON+rrsHUOlGeItEX62SQQh5YfMB0GA1UdDgQWBBSR6aH1PDM4iTtuGDa0ci+taEWHeTAaBgNVHREEEzARgg9jaGF0Lm9wZW5haS5jb20wPgYDVR0gBDcwNTAzBgZngQwBAgIwKTAnBggrBgEFBQcCARYbaHR0cDovL3d3dy5kaWdpY2VydC5jb20vQ1BTMA4GA1UdDwEB/wQEAwIDiDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwewYDVR0fBHQwcjA3oDWgM4YxaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0Nsb3VkZmxhcmVJbmNFQ0NDQS0zLmNybDA3oDWgM4YxaHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0Nsb3VkZmxhcmVJbmNFQ0NDQS0zLmNybDB2BggrBgEFBQcBAQRqMGgwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBABggrBgEFBQcwAoY0aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0Nsb3VkZmxhcmVJbmNFQ0NDQS0zLmNydDAMBgNVHRMBAf8EAjAAMIIBfwYKKwYBBAHWeQIEAgSCAW8EggFrAWkAdgDuzdBk1dsazsVct520zROiModGfLzs3sNRSFlGcR+1mwAAAYtpJO4UAAAEAwBHMEUCIQCeR80NFsZ961ocA8DIFtGkwX+MnQ6Ryp8x9tUs7jcbPgIgE5JNCvaagJwIMC8AFYoPMczWedJubjclrItI5SpJ0gEAdgBIsONr2qZHNA/lagL6nTDrHFIBy1bdLIHZu7+rOdiEcwAAAYtpJO4YAAAEAwBHMEUCIEaLHTthPluTtu7wHFcn3rP1IaNY4oyAK+fEaX4M+LzTAiEAgfnXCLZXb1EFj0X76v1FRdWAFMRUfFtkxOpJvCxO7CEAdwDatr9rP7W2Ip+bwrtca+hwkXFsu1GEhTS9pD0wSNf7qwAAAYtpJO5GAAAEAwBIMEYCIQCz3Iiv0ocincv60Ewqc72M+WRtT7s8UVOWinZdymJ/vgIhAIffJ2B2RL2JSOIwM2RFtvMWH4tWtvoITeM90GhyrcM8MAoGCCqGSM49BAMCA0cAMEQCIAnLrRHKoNYvyqd77IFmBKKhUlKHieUsPayLDB4sn50KAiB44aQ9lfDJIXiabR2bKrIK2uRh9tsuQz146L4BAFT7Gw=="
  
  static var x5cLeafCertificateBase64 = "TUlJRkRUQ0NCTFNnQXdJQkFnSVFEZkdwMUxsZExhWmtuQXFmTm02bWpqQUtCZ2dxaGtqT1BRUURBakJLTVFzd0NRWURWUVFHRXdKVlV6RVpNQmNHQTFVRUNoTVFRMnh2ZFdSbWJHRnlaU3dnU1c1akxqRWdNQjRHQTFVRUF4TVhRMnh2ZFdSbWJHRnlaU0JKYm1NZ1JVTkRJRU5CTFRNd0hoY05Nak14TURJMU1EQXdNREF3V2hjTk1qUXhNREl6TWpNMU9UVTVXakJ2TVFzd0NRWURWUVFHRXdKVlV6RVRNQkVHQTFVRUNCTUtRMkZzYVdadmNtNXBZVEVXTUJRR0ExVUVCeE1OVTJGdUlFWnlZVzVqYVhOamJ6RVpNQmNHQTFVRUNoTVFRMnh2ZFdSbWJHRnlaU3dnU1c1akxqRVlNQllHQTFVRUF4TVBZMmhoZEM1dmNHVnVZV2t1WTI5dE1Ga3dFd1lIS29aSXpqMENBUVlJS29aSXpqMERBUWNEUWdBRUxZaWExWWNyVk1aRGR0MjFqS0FWUDAwRDFoV3dKYlgzUGQyU0VSZHpMeVVxcjhDVzhwL245WU8yQmRnc3N6ZWtiMVhYN0NnV2ZtWmZzMDhEZkRjUE1hT0NBMVV3Z2dOUk1COEdBMVVkSXdRWU1CYUFGS1hPTitycnNIVU9sR2VJdEVYNjJTUVFoNVlmTUIwR0ExVWREZ1FXQkJTUjZhSDFQRE00aVR0dUdEYTBjaSt0YUVXSGVUQWFCZ05WSFJFRUV6QVJnZzlqYUdGMExtOXdaVzVoYVM1amIyMHdQZ1lEVlIwZ0JEY3dOVEF6QmdabmdRd0JBZ0l3S1RBbkJnZ3JCZ0VGQlFjQ0FSWWJhSFIwY0RvdkwzZDNkeTVrYVdkcFkyVnlkQzVqYjIwdlExQlRNQTRHQTFVZER3RUIvd1FFQXdJRGlEQWRCZ05WSFNVRUZqQVVCZ2dyQmdFRkJRY0RBUVlJS3dZQkJRVUhBd0l3ZXdZRFZSMGZCSFF3Y2pBM29EV2dNNFl4YUhSMGNEb3ZMMk55YkRNdVpHbG5hV05sY25RdVkyOXRMME5zYjNWa1pteGhjbVZKYm1ORlEwTkRRUzB6TG1OeWJEQTNvRFdnTTRZeGFIUjBjRG92TDJOeWJEUXVaR2xuYVdObGNuUXVZMjl0TDBOc2IzVmtabXhoY21WSmJtTkZRME5EUVMwekxtTnliREIyQmdnckJnRUZCUWNCQVFScU1HZ3dKQVlJS3dZQkJRVUhNQUdHR0doMGRIQTZMeTl2WTNOd0xtUnBaMmxqWlhKMExtTnZiVEJBQmdnckJnRUZCUWN3QW9ZMGFIUjBjRG92TDJOaFkyVnlkSE11WkdsbmFXTmxjblF1WTI5dEwwTnNiM1ZrWm14aGNtVkpibU5GUTBORFFTMHpMbU55ZERBTUJnTlZIUk1CQWY4RUFqQUFNSUlCZndZS0t3WUJCQUhXZVFJRUFnU0NBVzhFZ2dGckFXa0FkZ0R1emRCazFkc2F6c1ZjdDUyMHpST2lNb2RHZkx6czNzTlJTRmxHY1IrMW13QUFBWXRwSk80VUFBQUVBd0JITUVVQ0lRQ2VSODBORnNaOTYxb2NBOERJRnRHa3dYK01uUTZSeXA4eDl0VXM3amNiUGdJZ0U1Sk5DdmFhZ0p3SU1DOEFGWW9QTWN6V2VkSnViamNsckl0STVTcEowZ0VBZGdCSXNPTnIycVpITkEvbGFnTDZuVERySEZJQnkxYmRMSUhadTcrck9kaUVjd0FBQVl0cEpPNFlBQUFFQXdCSE1FVUNJRWFMSFR0aFBsdVR0dTd3SEZjbjNyUDFJYU5ZNG95QUsrZkVhWDRNK0x6VEFpRUFnZm5YQ0xaWGIxRUZqMFg3NnYxRlJkV0FGTVJVZkZ0a3hPcEp2Q3hPN0NFQWR3RGF0cjlyUDdXMklwK2J3cnRjYStod2tYRnN1MUdFaFRTOXBEMHdTTmY3cXdBQUFZdHBKTzVHQUFBRUF3QklNRVlDSVFDejNJaXYwb2NpbmN2NjBFd3FjNzJNK1dSdFQ3czhVVk9XaW5aZHltSi92Z0loQUlmZkoyQjJSTDJKU09Jd00yUkZ0dk1XSDR0V3R2b0lUZU05MEdoeXJjTThNQW9HQ0NxR1NNNDlCQU1DQTBjQU1FUUNJQW5MclJIS29OWXZ5cWQ3N0lGbUJLS2hVbEtIaWVVc1BheUxEQjRzbjUwS0FpQjQ0YVE5bGZESklYaWFiUjJiS3JJSzJ1Umg5dHN1UXoxNDZMNEJBRlQ3R3c9PQ=="
  
  static var x5cInterCertificate = "MIIDzTCCArWgAwIBAgIQCjeHZF5ftIwiTv0b7RQMPDANBgkqhkiG9w0BAQsFADBaMQswCQYDVQQGEwJJRTESMBAGA1UEChMJQmFsdGltb3JlMRMwEQYDVQQLEwpDeWJlclRydXN0MSIwIAYDVQQDExlCYWx0aW1vcmUgQ3liZXJUcnVzdCBSb290MB4XDTIwMDEyNzEyNDgwOFoXDTI0MTIzMTIzNTk1OVowSjELMAkGA1UEBhMCVVMxGTAXBgNVBAoTEENsb3VkZmxhcmUsIEluYy4xIDAeBgNVBAMTF0Nsb3VkZmxhcmUgSW5jIEVDQyBDQS0zMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEua1NZpkUC0bsH4HRKlAenQMVLzQSfS2WuIg4m4Vfj7+7Te9hRsTJc9QkT+DuHM5ss1FxL2ruTAUJd9NyYqSb16OCAWgwggFkMB0GA1UdDgQWBBSlzjfq67B1DpRniLRF+tkkEIeWHzAfBgNVHSMEGDAWgBTlnVkwgkdYzKz6CFQ2hns6tQRN8DAOBgNVHQ8BAf8EBAMCAYYwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMBIGA1UdEwEB/wQIMAYBAf8CAQAwNAYIKwYBBQUHAQEEKDAmMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wOgYDVR0fBDMwMTAvoC2gK4YpaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL09tbmlyb290MjAyNS5jcmwwbQYDVR0gBGYwZDA3BglghkgBhv1sAQEwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzALBglghkgBhv1sAQIwCAYGZ4EMAQIBMAgGBmeBDAECAjAIBgZngQwBAgMwDQYJKoZIhvcNAQELBQADggEBAAUkHd0bsCrrmNaF4zlNXmtXnYJX/OvoMaJXkGUFvhZEOFp3ArnPEELG4ZKk40Un+ABHLGioVplTVI+tnkDB0A+21w0LOEhsUCxJkAZbZB2LzEgwLt4I4ptJIsCSDBFelpKU1fwg3FZs5ZKTv3ocwDfjhUkV+ivhdDkYD7fa86JXWGBPzI6UAPxGezQxPk1HgoE6y/SJXQ7vTQ1unBuCJN0yJV0ReFEQPaA1IwQvZW+cwdFD19Ae8zFnWSfda9J1CZMRJCQUzym+5iPDuI9yP+kHyCREU3qzuWFloUwOxkgAyXVjBYdwRVKD05WdRerw6DEdfgkfCv4+3ao8XnTSrLE="
  
  static var x5cInterCertificateBase64 = "TUlJRHpUQ0NBcldnQXdJQkFnSVFDamVIWkY1ZnRJd2lUdjBiN1JRTVBEQU5CZ2txaGtpRzl3MEJBUXNGQURCYU1Rc3dDUVlEVlFRR0V3SkpSVEVTTUJBR0ExVUVDaE1KUW1Gc2RHbHRiM0psTVJNd0VRWURWUVFMRXdwRGVXSmxjbFJ5ZFhOME1TSXdJQVlEVlFRREV4bENZV3gwYVcxdmNtVWdRM2xpWlhKVWNuVnpkQ0JTYjI5ME1CNFhEVEl3TURFeU56RXlORGd3T0ZvWERUSTBNVEl6TVRJek5UazFPVm93U2pFTE1Ba0dBMVVFQmhNQ1ZWTXhHVEFYQmdOVkJBb1RFRU5zYjNWa1pteGhjbVVzSUVsdVl5NHhJREFlQmdOVkJBTVRGME5zYjNWa1pteGhjbVVnU1c1aklFVkRReUJEUVMwek1Ga3dFd1lIS29aSXpqMENBUVlJS29aSXpqMERBUWNEUWdBRXVhMU5acGtVQzBic0g0SFJLbEFlblFNVkx6UVNmUzJXdUlnNG00VmZqNys3VGU5aFJzVEpjOVFrVCtEdUhNNXNzMUZ4TDJydVRBVUpkOU55WXFTYjE2T0NBV2d3Z2dGa01CMEdBMVVkRGdRV0JCU2x6amZxNjdCMURwUm5pTFJGK3Rra0VJZVdIekFmQmdOVkhTTUVHREFXZ0JUbG5Wa3dna2RZekt6NkNGUTJobnM2dFFSTjhEQU9CZ05WSFE4QkFmOEVCQU1DQVlZd0hRWURWUjBsQkJZd0ZBWUlLd1lCQlFVSEF3RUdDQ3NHQVFVRkJ3TUNNQklHQTFVZEV3RUIvd1FJTUFZQkFmOENBUUF3TkFZSUt3WUJCUVVIQVFFRUtEQW1NQ1FHQ0NzR0FRVUZCekFCaGhob2RIUndPaTh2YjJOemNDNWthV2RwWTJWeWRDNWpiMjB3T2dZRFZSMGZCRE13TVRBdm9DMmdLNFlwYUhSMGNEb3ZMMk55YkRNdVpHbG5hV05sY25RdVkyOXRMMDl0Ym1seWIyOTBNakF5TlM1amNtd3diUVlEVlIwZ0JHWXdaREEzQmdsZ2hrZ0JodjFzQVFFd0tqQW9CZ2dyQmdFRkJRY0NBUlljYUhSMGNITTZMeTkzZDNjdVpHbG5hV05sY25RdVkyOXRMME5RVXpBTEJnbGdoa2dCaHYxc0FRSXdDQVlHWjRFTUFRSUJNQWdHQm1lQkRBRUNBakFJQmdabmdRd0JBZ013RFFZSktvWklodmNOQVFFTEJRQURnZ0VCQUFVa0hkMGJzQ3JybU5hRjR6bE5YbXRYbllKWC9Pdm9NYUpYa0dVRnZoWkVPRnAzQXJuUEVFTEc0WktrNDBVbitBQkhMR2lvVnBsVFZJK3Rua0RCMEErMjF3MExPRWhzVUN4SmtBWmJaQjJMekVnd0x0NEk0cHRKSXNDU0RCRmVscEtVMWZ3ZzNGWnM1WktUdjNvY3dEZmpoVWtWK2l2aGREa1lEN2ZhODZKWFdHQlB6STZVQVB4R2V6UXhQazFIZ29FNnkvU0pYUTd2VFExdW5CdUNKTjB5SlYwUmVGRVFQYUExSXdRdlpXK2N3ZEZEMTlBZTh6Rm5XU2ZkYTlKMUNaTVJKQ1FVenltKzVpUER1STl5UCtrSHlDUkVVM3F6dVdGbG9Vd094a2dBeVhWakJZZHdSVktEMDVXZFJlcnc2REVkZmdrZkN2NCszYW84WG5UU3JMRT0="
  
  static var sdJwt = "eyJhbGciOiAiRVMyNTYiLCAidHlwIjogInZjK3NkLWp3dCIsICJ4NWMiOiBbIk1JSURBRENDQW9hZ0F3SUJBZ0lVR2F6SzNndW5wMkFrVnpvODI0a0JHNGhWKzFnd0NnWUlLb1pJemowRUF3SXdYREVlTUJ3R0ExVUVBd3dWVUVsRUlFbHpjM1ZsY2lCRFFTQXRJRlZVSURBeE1TMHdLd1lEVlFRS0RDUkZWVVJKSUZkaGJHeGxkQ0JTWldabGNtVnVZMlVnU1cxd2JHVnRaVzUwWVhScGIyNHhDekFKQmdOVkJBWVRBbFZVTUI0WERUSTFNREV4TkRFeU5UY3lNMW9YRFRJMk1EUXdPVEV5TlRjeU1sb3dVekVWTUJNR0ExVUVBd3dNVUVsRUlFUlRJQzBnTURBek1TMHdLd1lEVlFRS0RDUkZWVVJKSUZkaGJHeGxkQ0JTWldabGNtVnVZMlVnU1cxd2JHVnRaVzUwWVhScGIyNHhDekFKQmdOVkJBWVRBbFZVTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFQXk1Mlo0ZG9RNk1DZEF1RzFVOWZGRmZLdmxobUdibXRTVlhkRjdCTnl2a3RtUWJjaDU4aFpPZkl0SDhqMjl3Y1UzT0dmM25ORW8xRkc4bzF2T29yYTZPQ0FTMHdnZ0VwTUI4R0ExVWRJd1FZTUJhQUZMTnN1SkVYSE5la0dtWXhoMExoaThCQXpKVWJNQnNHQTFVZEVRUVVNQktDRUdsemMzVmxjaTVsZFdScGR5NWtaWFl3RmdZRFZSMGxBUUgvQkF3d0NnWUlLNEVDQWdBQUFRSXdRd1lEVlIwZkJEd3dPakE0b0RhZ05JWXlhSFIwY0hNNkx5OXdjbVZ3Y205a0xuQnJhUzVsZFdScGR5NWtaWFl2WTNKc0wzQnBaRjlEUVY5VlZGOHdNUzVqY213d0hRWURWUjBPQkJZRUZIN1FJR1FTYkxncURTOFBkcTVVdS9JeVgzK0lNQTRHQTFVZER3RUIvd1FFQXdJSGdEQmRCZ05WSFJJRVZqQlVobEpvZEhSd2N6b3ZMMmRwZEdoMVlpNWpiMjB2WlhVdFpHbG5hWFJoYkMxcFpHVnVkR2wwZVMxM1lXeHNaWFF2WVhKamFHbDBaV04wZFhKbExXRnVaQzF5WldabGNtVnVZMlV0Wm5KaGJXVjNiM0pyTUFvR0NDcUdTTTQ5QkFNQ0EyZ0FNR1VDTUZoNEUrU2JvZ3hGRHphbFF0M3RWV1drY3F4NmhjSW1VUTZVVndMZUJXUFJvS2dweUNueUdwK3lMSERXckd2b09RSXhBTzE1NUFIK1QzTWcxNE9jNlFuYzZIdDZvK1l1SU44NnZvTzZHa3djb25Ic3JjQlNqNVR3SmNxTkI1cXRmN0kxOXc9PSJdfQ.eyJfc2QiOiBbIi0xc2h1bklfajZmcjgtUlJSQ0V4TDlLUEZmQTNIVFJhY01CSGFMRmdKOE0iLCAiQjhWeXBILWotcVNORWppLTNiNGZtdUJ3cnI4eWJlbmFWR3B1WjYtVm5UQSIsICJGTGpTbndsUmpyUkFGT3BuaW9YSDdyOWNhcFQtdlExYlFhOFJSYnVlcFpJIiwgIlB1NUY5WjB4bTRQbUtIWFl6OWVWTTgtM2M0Unk5LWE5bTM3Y0FvMklPRTgiLCAiU0wxNHNoLWlLVmxPOWNGUC1MT2Zqd3B2VDFsbV9uUFZDYTJDU2V4UlgxdyIsICJycWxicnNWMTc1Vlk4b1BmWi10ZVpGMWpBRmhrT3dZVUgtRTZCQkpPUTdrIl0sICJpc3MiOiAiaHR0cHM6Ly9kZXYuaXNzdWVyLmV1ZGl3LmRldiIsICJpYXQiOiAxNzM3Njc2ODAwLCAiZXhwIjogMTc0NTQ0OTIwMCwgInZjdCI6ICJ1cm46ZXUuZXVyb3BhLmVjLmV1ZGk6cGlkOjEiLCAic3RhdHVzIjogeyJpZGVudGlmaWVyX2xpc3QiOiB7ImlkIjogOTMsICJ1cmkiOiAiaHR0cHM6Ly9pc3N1ZXIuZXVkaXcuZGV2L2lkZW50aWZpZXJfbGlzdC9GQy9ldS5ldXJvcGEuZWMuZXVkaS5waWQuMS8zMzAwZjBhNS1jNWQ3LTQwNzUtOWFiOC1kMWYxOTkyZTU3ZmIifSwgInN0YXR1c19saXN0IjogeyJpZHgiOiA5MywgInVyaSI6ICJodHRwczovL2lzc3Vlci5ldWRpdy5kZXYvdG9rZW5fc3RhdHVzX2xpc3QvRkMvZXUuZXVyb3BhLmVjLmV1ZGkucGlkLjEvMzMwMGYwYTUtYzVkNy00MDc1LTlhYjgtZDFmMTk5MmU1N2ZiIn19LCAiX3NkX2FsZyI6ICJzaGEtMjU2IiwgImNuZiI6IHsiandrIjogeyJrdHkiOiAiRUMiLCAiY3J2IjogIlAtMjU2IiwgIngiOiAiemZ3Tkh6dXhFUjJVMEJiVVE5SllQZUZXYWZXM2l2V3cxTTNUWk5rbHEyNCIsICJ5IjogIkQ2Z3htQWNLbE0xM1FTcEFrWUxzVUI1Q09nMTJOT18zWE9oT2NjbXpQT00ifX19.m3XrLBrnUqg8PtW6Yrcf1XniHstKjZxnNUYYgW7bPq-0X0hZ0rO-hEGhS74_19fjHWo9PTvrU0dJrBYlroOvfQ~WyJFbDVWUnBEMnNKNjk2dzVkeF9sS1BBIiwgImJpcnRoZGF0ZSIsICIxOTU2LTAxLTI0Il0~WyJvMVhJUmxpS1VSUGpHN01lVmdXT3dnIiwgImlzc3VpbmdfY291bnRyeSIsICJGQyJd~WyJPdTVFSnVBYzJsT2gtWFdaVUF1NGFnIiwgImdpdmVuX25hbWUiLCAibGFzdCJd~WyJhZUdMYmctRktTQzBXQjZCZFNOWDhnIiwgImlzc3VpbmdfYXV0aG9yaXR5IiwgIlRlc3QgUElEIGlzc3VlciJd~WyJnRGxsLTE3QlJabzZXclEtVWlweHF3IiwgIjE4IiwgdHJ1ZV0~WyJRUGJzZ1ZuZTNzOFVuSzBDX1NqM2VRIiwgImFnZV9lcXVhbF9vcl9vdmVyIiwgeyJfc2QiOiBbImRXdFBLUUZjQVIxYmZHX1FoN1dzbjZWSFdxblpUUjRaeU82ZGVDcExGYzgiXX1d~WyJmbUtUajI5dUFVN2hrQ2lEa2hodEVRIiwgImZhbWlseV9uYW1lIiwgImZpcnN0Il0~eyJhbGciOiJFUzI1NiIsInR5cCI6ImtiK2p3dCJ9.eyJhdWQiOiJ2ZXJpZmllci1iYWNrZW5kLmV1ZGl3LmRldiIsIm5vbmNlIjoiYjcwZjE3MTYtZjZjYS00NWE3LWFkMjQtZjliNmIwYTVkMDc3IiwiaWF0IjoxNzM4MzE1NDk2LCJzZF9oYXNoIjoiQ28tejY4ZmI1RkJpcXNZX05DbXR3TWJ6WFBFbktnUWVkMTE4M0RHLUlHZyJ9.LsM1xZpNc0twIR5unn9fsOFTpfBSptmRttQ-3MmiRkIIuHgUYh5BqVIAqPkDwqu27tBSM4csjCK_fOZu9--Fqw"
  
  static func generateMdocGeneratedNonce() -> String {
    var bytes = [UInt8](repeating: 0, count: 16)
    let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    if result != errSecSuccess {
      bytes = (0 ..< 16).map { _ in UInt8.random(in: UInt8.min ... UInt8.max) }
    }
    return Data(bytes).base64URLEncodedString()
  }
  
  static func presentationSubmission(_ presentationDefinition: PresentationDefinition) -> PresentationSubmission {
    .init(
      id: UUID().uuidString,
      definitionID: presentationDefinition.id,
      descriptorMap:
        presentationDefinition.inputDescriptors.filter {
          $0.formatContainer?.formats.contains(
            where: { $0["designation"].string?.lowercased() == "mso_mdoc"
            }) ?? false
        }.map { DescriptorMap(
          id: $0.id,
          format: "mso_mdoc",
          path: "$"
        )
      }
    )
  }
  
  public static func testVpFormatsTO() -> VpFormatsTO {
    .init(
      vcSdJwt: .init(
        sdJwtAlgorithms: ["PS256"],
        kdJwtAlgorithms: ["PS256"]
      )
    )
  }
}

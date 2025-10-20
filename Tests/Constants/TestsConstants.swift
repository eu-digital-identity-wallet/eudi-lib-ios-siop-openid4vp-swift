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
import CryptoKit
import CryptoSwift
import JOSESwift
import Security

@testable import SiopOpenID4VP

struct TestsConstants {
  
  public static func testClientMetaData() -> ClientMetaData {
    .init(
      jwks: "jwks",
      idTokenSignedResponseAlg: ".idTokenSignedResponseAlg",
      idTokenEncryptedResponseAlg: ".idTokenEncryptedResponseAlg",
      idTokenEncryptedResponseEnc: ".idTokenEncryptedResponseEnc",
      subjectSyntaxTypesSupported: [],
      vpFormatsSupported: Self.testVpFormatsSupportedTO()
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
      vpFormatsSupported: try! VpFormatsSupported(from: TestsConstants.testVpFormatsSupportedTO())!
    )
  }
  
  public static let testClientId = "dev.verifier-backend.eudiw.dev"
  public static let clientId = "x509_san_dns:\(Self.testClientId)"
  
  public static let testNonce = "0S6_WzA2Mj"
  public static let testScope = "one two three"
  
  public static let testResponseMode: ResponseMode = .directPost(responseURI: URL(string: "https://respond.here")!)
  
  public static let header = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
  public static let payload = "eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0"
  public static let signature = "tyh-VfuzIxCyGYDlkBA7DfyjrqmSHu6pQ2hoZuFqUSLPNY2N0mpHb3nk5K17HWP_3cYHBw7AhHale5wky6-sVA"
  
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
    let signature = CryptoKit.HMAC<SHA256>.authenticationCode(for: Data(encodedToken.utf8), using: SymmetricKey(data: secretKey))
    
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
  
  static let sampleClientMetaData = #"{"id_token_signed_response_alg":"value_id_token_signed_response_alg","id_token_encrypted_response_alg":"value_id_token_encrypted_response_alg","id_token_encrypted_response_enc":"value_id_token_encrypted_response_enc","subject_syntax_types_supported":["value_subject_syntax_types_supported"]}"#
  
  static let sampleValidClientMetaData = #"{"jwks":{"keys":[{"kty":"RSA", "e":"AQAB", "use":"sig", "kid":"a4e1bbe6-26e8-480b-a364-f43497894453", "iat":1683559586, "n":"xHI9zoXS-fOAFXDhDmPMmT_UrU1MPimy0xfP-sL0Iu4CQJmGkALiCNzJh9v343fqFT2hfrbigMnafB2wtcXZeEDy6Mwu9QcJh1qLnklW5OOdYsLJLTyiNwMbLQXdVxXiGby66wbzpUymrQmT1v80ywuYd8Y0IQVyteR2jvRDNxy88bd2eosfkUdQhNKUsUmpODSxrEU2SJCClO4467fVdPng7lyzF2duStFeA2vUkZubor3EcrJ72JbZVI51YDAqHQyqKZIDGddOOvyGUTyHz9749bsoesqXHOugVXhc2elKvegwBik3eOLgfYKJwisFcrBl62k90RaMZpXCxNO4Ew"}]},"id_token_signed_response_alg":"value_id_token_signed_response_alg","id_token_encrypted_response_alg":"value_id_token_encrypted_response_alg","id_token_encrypted_response_enc":"value_id_token_encrypted_response_enc","subject_syntax_types_supported":["value_subject_syntax_types_supported"]}"#
  
  static let sampleValidJWKS = #"{"keys":[{"kty":"RSA", "e":"AQAB", "use":"sig", "kid":"9556a7a5-bb4f-4354-9208-74789528d1c7", "iat":1691595131, "n":"087NDoY9u7QUYAd-hjzx0B7k5_jofB1-wgRWGpFtpFmBkWMPCHtH72E240xkEO_nrgyEPJvh5-K6V--9MHevBCw1ihR-GtiCK4LEtY6alTWJx90yFEwiwHqVTzWpGDZSyRb3QGgjSgqWlYeIHkro58EykYyVCXr9m5PuyiM1Uekt6PXAZdWYFBeT8v1bjwe8knVEayC7U5eVkScabGcGGUWRFeOVbkS6vR18PCJ8nokHQipISpgD2pdD29Vn39Aped3hd7tdVJj-C7qZwIuAEUeRzxXeKdLRxmZvj_oX_Q39XzNVpMVO8IQSrKvqPKvQUNABboxb24L7pK1b9F0S4w"}]}"#
  
  // MARK: - Client meta data by value, Presentation definition by reference
  
  static let validVpTokenByClientByValuePresentationByReferenceUrlString =
  "eudi-wallet://authorize?" +
  "response_type=vp_token" +
  "&client_id=verifier-backend.eudiw.dev" +
  "&client_id_scheme=pre-registered" +
  "&client_metadata={\"jwks\":{\"keys\":[{\"kty\":\"RSA\", \"e\":\"AQAB\", \"use\":\"sig\", \"kid\":\"a4e1bbe6-26e8-480b-a364-f43497894453\", \"iat\":1683559586, \"n\":\"xHI9zoXS-fOAFXDhDmPMmT_UrU1MPimy0xfP-sL0Iu4CQJmGkALiCNzJh9v343fqFT2hfrbigMnafB2wtcXZeEDy6Mwu9QcJh1qLnklW5OOdYsLJLTyiNwMbLQXdVxXiGby66wbzpUymrQmT1v80ywuYd8Y0IQVyteR2jvRDNxy88bd2eosfkUdQhNKUsUmpODSxrEU2SJCClO4467fVdPng7lyzF2duStFeA2vUkZubor3EcrJ72JbZVI51YDAqHQyqKZIDGddOOvyGUTyHz9749bsoesqXHOugVXhc2elKvegwBik3eOLgfYKJwisFcrBl62k90RaMZpXCxNO4Ew\"}]}, \"id_token_signed_respons e_alg\":\"value_id_token_signed_response_alg\",\"id_token_encrypted_response_alg\":\"value_id_token_encrypted_response_alg\",\"id_token_encrypted_response_enc\":\"value_id_token_encrypted_response_enc\",\"subject_syntax_types_supported\":[\"value_subject_syntax_types_supported\"],\"vp_formats_supported\":{\"dc+sd-jwt\":{\"sd-jwt_alg_values\":[\"ES256\"],\"kb-jwt_alg_values\":[\"ES256\"]}}}" +
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
  "&client_metadata={\"jwks\":{\"keys\":[{\"kty\":\"RSA\", \"e\":\"AQAB\", \"use\":\"sig\", \"kid\":\"a4e1bbe6-26e8-480b-a364-f43497894453\", \"iat\":1683559586, \"n\":\"xHI9zoXS-fOAFXDhDmPMmT_UrU1MPimy0xfP-sL0Iu4CQJmGkALiCNzJh9v343fqFT2hfrbigMnafB2wtcXZeEDy6Mwu9QcJh1qLnklW5OOdYsLJLTyiNwMbLQXdVxXiGby66wbzpUymrQmT1v80ywuYd8Y0IQVyteR2jvRDNxy88bd2eosfkUdQhNKUsUmpODSxrEU2SJCClO4467fVdPng7lyzF2duStFeA2vUkZubor3EcrJ72JbZVI51YDAqHQyqKZIDGddOOvyGUTyHz9749bsoesqXHOugVXhc2elKvegwBik3eOLgfYKJwisFcrBl62k90RaMZpXCxNO4Ew\"}]},\"id_token_signed_response_alg\":\"value_id_token_signed_response_alg\",\"id_token_encrypted_response_alg\":\"value_id_token_encrypted_response_alg\",\"id_token_encrypted_response_enc\":\"value_id_token_encrypted_response_enc\",\"subject_syntax_types_supported\":[\"value_subject_syntax_types_supported\"],\"vp_formats_supported\":{\"dc+sd-jwt\":{\"sd-jwt_alg_values\":[\"ES256\"],\"kb-jwt_alg_values\":[\"ES256\"]}}}" +
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
  "&client_metadata={\"jwks\":{\"keys\":[{\"kty\":\"RSA\", \"e\":\"AQAB\", \"use\":\"sig\", \"kid\":\"a4e1bbe6-26e8-480b-a364-f43497894453\", \"iat\":1683559586, \"n\":\"xHI9zoXS-fOAFXDhDmPMmT_UrU1MPimy0xfP-sL0Iu4CQJmGkALiCNzJh9v343fqFT2hfrbigMnafB2wtcXZeEDy6Mwu9QcJh1qLnklW5OOdYsLJLTyiNwMbLQXdVxXiGby66wbzpUymrQmT1v80ywuYd8Y0IQVyteR2jvRDNxy88bd2eosfkUdQhNKUsUmpODSxrEU2SJCClO4467fVdPng7lyzF2duStFeA2vUkZubor3EcrJ72JbZVI51YDAqHQyqKZIDGddOOvyGUTyHz9749bsoesqXHOugVXhc2elKvegwBik3eOLgfYKJwisFcrBl62k90RaMZpXCxNO4Ew\"}]},\"id_token_signed_response_alg\":\"value_id_token_signed_response_alg\",\"id_token_encrypted_response_alg\":\"value_id_token_encrypted_response_alg\",\"id_token_encrypted_response_enc\":\"value_id_token_encrypted_response_enc\",\"subject_syntax_types_supported\":[\"value_subject_syntax_types_supported\"],\"vp_formats_supported\":{\"dc+sd-jwt\":{\"sd-jwt_alg_values\":[\"ES256\"],\"kb-jwt_alg_values\":[\"ES256\"]}}}" +
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
  "eudi-wallet://authorized?client_id=Verifier&request_uri=https://eudi.netcompany-intrasoft.com/wallet/request.jwt/T9ZNgzH5XckvyABisd5lja-5PfUSn9or52Qg4sjb8s3qjb5gi9B1oSOtlU6XI4Y13YISeiHRlcVoSWpFafOI8g"
  
  static var requestExpiredUrl: URL {
    return URL(string: requestExpiredUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
  }
  
  static let requestObjectUrlString =
  "eudi-wallet://authorized?client_id=Verifier&request=eyJraWQiOiIzOWY0NGQzOS0wMzQ4LTRmNzktYjQ1Yy1jNTExMDkyNTU1NjYiLCJhbGciOiJSUzI1NiJ9.eyJyZXNwb25zZV91cmkiOiJodHRwczovL2ZvbyIsImNsaWVudF9pZF9zY2hlbWUiOiJwcmUtcmVnaXN0ZXJlZCIsInJlc3BvbnNlX3R5cGUiOiJ2cF90b2tlbiIsIm5vbmNlIjoiSEhqRDdiMGxMQVh0X0VNVk5EU1c2cHl2blowM05yYlJtSzBKMFJMUHozSlNZY01jMGhfeVZmYkd3VDRuWWtRYzNFR0FYWFNWS1pITkZmNGs5N3ZrdHciLCJjbGllbnRfaWQiOiJWZXJpZmllciIsInJlc3BvbnNlX21vZGUiOiJkaXJlY3RfcG9zdC5qd3QiLCJhdWQiOiJodHRwczovL3NlbGYtaXNzdWVkLm1lL3YyIiwic2NvcGUiOiIiLCJwcmVzZW50YXRpb25fZGVmaW5pdGlvbiI6eyJpZCI6IjMyZjU0MTYzLTcxNjYtNDhmMS05M2Q4LWZmMjE3YmRiMDY1MyIsImlucHV0X2Rlc2NyaXB0b3JzIjpbeyJpZCI6ImJhbmthY2NvdW50X2lucHV0IiwibmFtZSI6IkZ1bGwgQmFuayBBY2NvdW50IFJvdXRpbmcgSW5mb3JtYXRpb24iLCJwdXJwb3NlIjoiV2UgY2FuIG9ubHkgcmVtaXQgcGF5bWVudCB0byBhIGN1cnJlbnRseS12YWxpZCBiYW5rIGFjY291bnQsIHN1Ym1pdHRlZCBhcyBhbiBBQkEgUlROICsgQWNjdCAgb3IgSUJBTi4iLCJjb25zdHJhaW50cyI6eyJmaWVsZHMiOlt7InBhdGgiOlsiJC5jcmVkZW50aWFsU2NoZW1hLmlkIiwiJC52Yy5jcmVkZW50aWFsU2NoZW1hLmlkIl0sImZpbHRlciI6eyJ0eXBlIjoic3RyaW5nIiwiY29uc3QiOiJodHRwczovL2Jhbmstc3RhbmRhcmRzLmV4YW1wbGUuY29tL2Z1bGxhY2NvdW50cm91dGUuanNvbiJ9fSx7InBhdGgiOlsiJC5pc3N1ZXIiLCIkLnZjLmlzc3VlciIsIiQuaXNzIl0sInB1cnBvc2UiOiJXZSBjYW4gb25seSB2ZXJpZnkgYmFuayBhY2NvdW50cyBpZiB0aGV5IGFyZSBhdHRlc3RlZCBieSBhIHRydXN0ZWQgYmFuaywgYXVkaXRvciwgb3IgcmVndWxhdG9yeSBhdXRob3JpdHkuIiwiZmlsdGVyIjp7InR5cGUiOiJzdHJpbmciLCJwYXR0ZXJuIjoiZGlkOmV4YW1wbGU6MTIzfGRpZDpleGFtcGxlOjQ1NiJ9LCJpbnRlbnRfdG9fcmV0YWluIjp0cnVlfV19fSx7ImlkIjoidXNfcGFzc3BvcnRfaW5wdXQiLCJuYW1lIjoiVVMgUGFzc3BvcnQiLCJjb25zdHJhaW50cyI6eyJmaWVsZHMiOlt7InBhdGgiOlsiJC5jcmVkZW50aWFsU2NoZW1hLmlkIiwiJC52Yy5jcmVkZW50aWFsU2NoZW1hLmlkIl0sImZpbHRlciI6eyJ0eXBlIjoic3RyaW5nIiwiY29uc3QiOiJodWI6Ly9kaWQ6Zm9vOjEyMy9Db2xsZWN0aW9ucy9zY2hlbWEudXMuZ292L3Bhc3Nwb3J0Lmpzb24ifX0seyJwYXRoIjpbIiQuY3JlZGVudGlhbFN1YmplY3QuYmlydGhfZGF0ZSIsIiQudmMuY3JlZGVudGlhbFN1YmplY3QuYmlydGhfZGF0ZSIsIiQuYmlydGhfZGF0ZSJdLCJmaWx0ZXIiOnsidHlwZSI6InN0cmluZyIsImZvcm1hdCI6ImRhdGUifX1dfX1dfSwic3RhdGUiOiI5WTdNbnNEYVhBa2djejBwR19oVTFoUGZlQkVlTzFMaWJrWDdab3VLUHB3a05DNmI3WW1laW40MUN1VWszLUVvekw2TXVYcVhtcjVnTzRlaGNER0VxdyIsImlhdCI6MTY4MjcwNzE3OCwiY2xpZW50X21ldGFkYXRhIjp7Imp3a3MiOnsia2V5cyI6W3sia3R5IjoiUlNBIiwiZSI6IkFRQUIiLCJ1c2UiOiJzaWciLCJraWQiOiJhNGUxYmJlNi0yNmU4LTQ4MGItYTM2NC1mNDM0OTc4OTQ0NTMiLCJpYXQiOjE2ODM1NTk1ODYsIm4iOiJ4SEk5em9YUy1mT0FGWERoRG1QTW1UX1VyVTFNUGlteTB4ZlAtc0wwSXU0Q1FKbUdrQUxpQ056Smg5djM0M2ZxRlQyaGZyYmlnTW5hZkIyd3RjWFplRUR5Nk13dTlRY0poMXFMbmtsVzVPT2RZc0xKTFR5aU53TWJMUVhkVnhYaUdieTY2d2J6cFV5bXJRbVQxdjgweXd1WWQ4WTBJUVZ5dGVSMmp2UkROeHk4OGJkMmVvc2ZrVWRRaE5LVXNVbXBPRFN4ckVVMlNKQ0NsTzQ0NjdmVmRQbmc3bHl6RjJkdVN0RmVBMnZVa1p1Ym9yM0Vjcko3MkpiWlZJNTFZREFxSFF5cUtaSURHZGRPT3Z5R1VUeUh6OTc0OWJzb2VzcVhIT3VnVlhoYzJlbEt2ZWd3QmlrM2VPTGdmWUtKd2lzRmNyQmw2Mms5MFJhTVpwWEN4Tk80RXcifV19LCJpZF90b2tlbl9zaWduZWRfcmVzcG9uc2VfYWxnIjoiUlMyNTYiLCJpZF90b2tlbl9lbmNyeXB0ZWRfcmVzcG9uc2VfYWxnIjoiUlMyNTYiLCJpZF90b2tlbl9lbmNyeXB0ZWRfcmVzcG9uc2VfZW5jIjoiQTEyOENCQy1IUzI1NiIsInN1YmplY3Rfc3ludGF4X3R5cGVzX3N1cHBvcnRlZCI6WyJ1cm46aWV0ZjpwYXJhbXM6b2F1dGg6andrLXRodW1icHJpbnQiLCJkaWQ6ZXhhbXBsZSIsImRpZDprZXkiXX19.BKX9Es3dZVmXLQ7_Ggg32GJDvsM6FxlKdRhUXih6jRYhElohttJPCxHoNXHf6sUzB-7Qge6X7Hoel2H31rnYPOaOuZpI9zrIM8JuY_m3AmawHLwiNMRSb4CyBuCPhuQAoWwSeD0FjQzU-prTsT4t5YY-ep2AcujIccF_WFdCBAhilNh1AQx4YeGYA3uQ_OKAhd5luJgSjoZYQRkuCUdNt7l7nYrpWLxQZWT0-m3MUchAXVW9Tv3idhw-2fkeSxgVPXuf7v-T5KdmNbLRMrwMReTQ3n-x34yOhRZrenGzcrwicZoHXkeyPw7ut3UKtH4Ep-BCI4BTUupQkTIiziGU2Q"
  
  static var requestObjectUrl: URL {
    return URL(string: requestObjectUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
  }
  
  static let passByValueJWTURI = "https://us-central1-dx4b-4c2d822222222.cloudfunctions.net/api/request_jwt/mock_001"
  static let passByValueJWT = "eyJraWQiOiIzOWY0NGQzOS0wMzQ4LTRmNzktYjQ1Yy1jNTExMDkyNTU1NjYiLCJhbGciOiJSUzI1NiJ9.eyJyZXNwb25zZV91cmkiOiJodHRwczovL2ZvbyIsImNsaWVudF9pZF9zY2hlbWUiOiJwcmUtcmVnaXN0ZXJlZCIsInJlc3BvbnNlX3R5cGUiOiJ2cF90b2tlbiIsIm5vbmNlIjoiSEhqRDdiMGxMQVh0X0VNVk5EU1c2cHl2blowM05yYlJtSzBKMFJMUHozSlNZY01jMGhfeVZmYkd3VDRuWWtRYzNFR0FYWFNWS1pITkZmNGs5N3ZrdHciLCJjbGllbnRfaWQiOiJWZXJpZmllciIsInJlc3BvbnNlX21vZGUiOiJkaXJlY3RfcG9zdC5qd3QiLCJhdWQiOiJodHRwczovL3NlbGYtaXNzdWVkLm1lL3YyIiwic2NvcGUiOiIiLCJwcmVzZW50YXRpb25fZGVmaW5pdGlvbiI6eyJpZCI6IjMyZjU0MTYzLTcxNjYtNDhmMS05M2Q4LWZmMjE3YmRiMDY1MyIsImlucHV0X2Rlc2NyaXB0b3JzIjpbeyJpZCI6ImJhbmthY2NvdW50X2lucHV0IiwibmFtZSI6IkZ1bGwgQmFuayBBY2NvdW50IFJvdXRpbmcgSW5mb3JtYXRpb24iLCJwdXJwb3NlIjoiV2UgY2FuIG9ubHkgcmVtaXQgcGF5bWVudCB0byBhIGN1cnJlbnRseS12YWxpZCBiYW5rIGFjY291bnQsIHN1Ym1pdHRlZCBhcyBhbiBBQkEgUlROICsgQWNjdCAgb3IgSUJBTi4iLCJjb25zdHJhaW50cyI6eyJmaWVsZHMiOlt7InBhdGgiOlsiJC5jcmVkZW50aWFsU2NoZW1hLmlkIiwiJC52Yy5jcmVkZW50aWFsU2NoZW1hLmlkIl0sImZpbHRlciI6eyJ0eXBlIjoic3RyaW5nIiwiY29uc3QiOiJodHRwczovL2Jhbmstc3RhbmRhcmRzLmV4YW1wbGUuY29tL2Z1bGxhY2NvdW50cm91dGUuanNvbiJ9fSx7InBhdGgiOlsiJC5pc3N1ZXIiLCIkLnZjLmlzc3VlciIsIiQuaXNzIl0sInB1cnBvc2UiOiJXZSBjYW4gb25seSB2ZXJpZnkgYmFuayBhY2NvdW50cyBpZiB0aGV5IGFyZSBhdHRlc3RlZCBieSBhIHRydXN0ZWQgYmFuaywgYXVkaXRvciwgb3IgcmVndWxhdG9yeSBhdXRob3JpdHkuIiwiZmlsdGVyIjp7InR5cGUiOiJzdHJpbmciLCJwYXR0ZXJuIjoiZGlkOmV4YW1wbGU6MTIzfGRpZDpleGFtcGxlOjQ1NiJ9LCJpbnRlbnRfdG9fcmV0YWluIjp0cnVlfV19fSx7ImlkIjoidXNfcGFzc3BvcnRfaW5wdXQiLCJuYW1lIjoiVVMgUGFzc3BvcnQiLCJjb25zdHJhaW50cyI6eyJmaWVsZHMiOlt7InBhdGgiOlsiJC5jcmVkZW50aWFsU2NoZW1hLmlkIiwiJC52Yy5jcmVkZW50aWFsU2NoZW1hLmlkIl0sImZpbHRlciI6eyJ0eXBlIjoic3RyaW5nIiwiY29uc3QiOiJodWI6Ly9kaWQ6Zm9vOjEyMy9Db2xsZWN0aW9ucy9zY2hlbWEudXMuZ292L3Bhc3Nwb3J0Lmpzb24ifX0seyJwYXRoIjpbIiQuY3JlZGVudGlhbFN1YmplY3QuYmlydGhfZGF0ZSIsIiQudmMuY3JlZGVudGlhbFN1YmplY3QuYmlydGhfZGF0ZSIsIiQuYmlydGhfZGF0ZSJdLCJmaWx0ZXIiOnsidHlwZSI6InN0cmluZyIsImZvcm1hdCI6ImRhdGUifX1dfX1dfSwic3RhdGUiOiI5WTdNbnNEYVhBa2djejBwR19oVTFoUGZlQkVlTzFMaWJrWDdab3VLUHB3a05DNmI3WW1laW40MUN1VWszLUVvekw2TXVYcVhtcjVnTzRlaGNER0VxdyIsImlhdCI6MTY4MjcwNzE3OCwiY2xpZW50X21ldGFkYXRhIjp7Imp3a3NfdXJpIjoiaHR0cHM6Ly9qd2siLCJpZF90b2tlbl9zaWduZWRfcmVzcG9uc2VfYWxnIjoiUlMyNTYiLCJpZF90b2tlbl9lbmNyeXB0ZWRfcmVzcG9uc2VfYWxnIjoiUlMyNTYiLCJpZF90b2tlbl9lbmNyeXB0ZWRfcmVzcG9uc2VfZW5jIjoiQTEyOENCQy1IUzI1NiIsInN1YmplY3Rfc3ludGF4X3R5cGVzX3N1cHBvcnRlZCI6WyJ1cm46aWV0ZjpwYXJhbXM6b2F1dGg6andrLXRodW1icHJpbnQiLCJkaWQ6ZXhhbXBsZSIsImRpZDprZXkiXX19.jgrGjBcDTP5NlON2iYDQOdbr8h5vKLlbROeqg5JbBzRt3o0NIdb-KTCyB5msO9nLjVCnG6GnxfoUgOxUwpl1eKAvI0jpNDwba0jKFZec9AvBT-nSrMGrLKBEj83l2-yV8k1dH-CxKw19_td2bzfUjTYE_jJQPzpQ3ghLRUKVGslOOiScNq39L02O2eMOC00nxkMq6bBAzHUAcBt4-eZ4xd8Chgq7mqsx-phsiMCQ2sPEXTNNECreQrGDVnWAfRKoHVIfzD7ibKhJb8owN2Zs8KyFpMggdaeLHZ2Ce8VoqFFguuIlP8kf9r1p9KgF2gywIbdm0NPzbReWGNZWBiYj_g"
  
  static let nonNormativeUrlString =
  "eudi-wallet://authorize?" +
  "response_type=vp_token" +
  "&client_id=verifier-backend.eudiw.dev" +
  "&client_id_scheme=pre-registered" +
  "&redirect_uri=https://client.example.org/" +
  "&presentation_definition=%@" +
  "&nonce=n-0S6_WzA2Mj"
  
  static let nonNormativeOutOfScopeUrlString =
  "https://www.example.com/authorize?" +
  "response_type=vp_token" +
  "&client_id=verifier-backend.eudiw.dev" +
  "&client_id_scheme=redirect_uri" +
  "&redirect_uri=https://client.example.org/" +
  "&presentation_definition=%@" +
  "&nonce=n-0S6_WzA2Mj"
  
  static let nonNormativeByReferenceUrlString =
  "eudi-wallet://authorize?" +
  "response_type=vp_token" +
  "&client_id=https://client.example.org/" +
  "&client_id_scheme=pre-registered" +
  "&redirect_uri=https://client.example.org/" +
  "&presentation_definition_uri=%@" +
  "&nonce=n-0S6_WzA2Mj"
  
  static let nonNormativeScopesUrlString =
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
        "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"
      ],
      "x": "xtYEALUaP4YM7_IJJuBsXCmK89hYvMS8gs210K_tPHU",
      "y": "EsxPCxBp3DZB4FIr4BlmVYtGaUboVIihRBiQDo3MpWg",
      "exp": 1771986992
    }
  ]
}
"""
  
  static let webKeySet: WebKeySet = try! .init(webKeyJson)
  
  static var validByReferenceWebKeyUrl: URL {
    return URL(string: "https://verifier-backend.eudiw.dev/wallet/public-keys.json")!
  }
  
  static var validByReferenceWebKeyUrlString: String {
    return "https://verifier-backend.eudiw.dev/wallet/public-keys.json"
  }
  
  static let signedResponseAlg = "RS256"
  static let encryptedResponseAlg = "RSA-OAEP-256"
  static let encryptedResponseEnc = "A128CBC-HS256"
  static let subjectSyntaxTypesSupported = "urn:ietf:params:oauth:jwk-thumbprint"
  
  static let localHost = "http://localhost:8080"
  static let remoteHost = "https://\(Self.testClientId)"
  static let host = Self.remoteHost
  
  static let certCbor = "o2d2ZXJzaW9uYzEuMGlkb2N1bWVudHOBo2dkb2NUeXBleBhldS5ldXJvcGEuZWMuZXVkaXcucGlkLjFsaXNzdWVyU2lnbmVkompuYW1lU3BhY2VzoXgYZXUuZXVyb3BhLmVjLmV1ZGl3LnBpZC4xmB3YGFhZpGhkaWdlc3RJRBghZnJhbmRvbVC3GZQ4Vaowh4KULM5o7dhhcWVsZW1lbnRJZGVudGlmaWVya2ZhbWlseV9uYW1lbGVsZW1lbnRWYWx1ZWlBTkRFUlNTT07YGFhRpGhkaWdlc3RJRA1mcmFuZG9tUL-V-LtKk1Tnb2BD-75yb2dxZWxlbWVudElkZW50aWZpZXJqZ2l2ZW5fbmFtZWxlbGVtZW50VmFsdWVjSkFO2BhYW6RoZGlnZXN0SUQMZnJhbmRvbVDEd6i_vCHSwwUh0cYis_2EcWVsZW1lbnRJZGVudGlmaWVyamJpcnRoX2RhdGVsZWxlbWVudFZhbHVl2QPsajE5ODUtMDMtMzDYGFhPpGhkaWdlc3RJRAZmcmFuZG9tUC9Iodu5b6Z6RBIlCTasrgJxZWxlbWVudElkZW50aWZpZXJrYWdlX292ZXJfMThsZWxlbWVudFZhbHVl9dgYWFKkaGRpZ2VzdElEGCBmcmFuZG9tUOA2yxnnNGnBHl_-8Mnn_LZxZWxlbWVudElkZW50aWZpZXJsYWdlX2luX3llYXJzbGVsZW1lbnRWYWx1ZRgm2BhYVKRoZGlnZXN0SUQEZnJhbmRvbVD5ahR3sjQQA7vJvAmxHVwhcWVsZW1lbnRJZGVudGlmaWVybmFnZV9iaXJ0aF95ZWFybGVsZW1lbnRWYWx1ZRkHwdgYWFikaGRpZ2VzdElEGBtmcmFuZG9tUGvvcr45W1M-TOXWhqRtGGVxZWxlbWVudElkZW50aWZpZXJpdW5pcXVlX2lkbGVsZW1lbnRWYWx1ZWowMTI4MTk2NTMy2BhYXqRoZGlnZXN0SUQPZnJhbmRvbVCdK4qRNr7JWc2xdOA0bzjvcWVsZW1lbnRJZGVudGlmaWVycWZhbWlseV9uYW1lX2JpcnRobGVsZW1lbnRWYWx1ZWlBTkRFUlNTT07YGFhXpGhkaWdlc3RJRBdmcmFuZG9tUNtO_9G4ZlB1FNureyu40FFxZWxlbWVudElkZW50aWZpZXJwZ2l2ZW5fbmFtZV9iaXJ0aGxlbGVtZW50VmFsdWVjSkFO2BhYVaRoZGlnZXN0SUQOZnJhbmRvbVApwjr0dHp75VqkyCojGZkbcWVsZW1lbnRJZGVudGlmaWVya2JpcnRoX3BsYWNlbGVsZW1lbnRWYWx1ZWZTV0VERU7YGFhTpGhkaWdlc3RJRBVmcmFuZG9tUNZ7jedRLHgQ00_WB9umaIxxZWxlbWVudElkZW50aWZpZXJtYmlydGhfY291bnRyeWxlbGVtZW50VmFsdWViU0XYGFhSpGhkaWdlc3RJRBgZZnJhbmRvbVCN_FgslPAt6ncEwX4jv3NicWVsZW1lbnRJZGVudGlmaWVya2JpcnRoX3N0YXRlbGVsZW1lbnRWYWx1ZWJTRdgYWFqkaGRpZ2VzdElEGBhmcmFuZG9tUAlRldKQE3gdvstn8eAE48JxZWxlbWVudElkZW50aWZpZXJqYmlydGhfY2l0eWxlbGVtZW50VmFsdWVrS0FUUklORUhPTE3YGFhkpGhkaWdlc3RJRBgeZnJhbmRvbVCMsClpQzri9Ts3rvrGQyNHcWVsZW1lbnRJZGVudGlmaWVycHJlc2lkZW50X2FkZHJlc3NsZWxlbWVudFZhbHVlb0ZPUlRVTkFHQVRBTiAxNdgYWFakaGRpZ2VzdElEC2ZyYW5kb21QeJHFNssLiRkDK8XFJFGuQHFlbGVtZW50SWRlbnRpZmllcnByZXNpZGVudF9jb3VudHJ5bGVsZW1lbnRWYWx1ZWJTRdgYWFWkaGRpZ2VzdElEGBpmcmFuZG9tUFf3D57jOLFNyMGkPOeq439xZWxlbWVudElkZW50aWZpZXJucmVzaWRlbnRfc3RhdGVsZWxlbWVudFZhbHVlYlNF2BhYXKRoZGlnZXN0SUQTZnJhbmRvbVBWB0GNrKdBQVrlpImIRgUUcWVsZW1lbnRJZGVudGlmaWVybXJlc2lkZW50X2NpdHlsZWxlbWVudFZhbHVla0tBVFJJTkVIT0xN2BhYXaRoZGlnZXN0SUQSZnJhbmRvbVDsZlLl2N7J71jX-6bXsnwEcWVsZW1lbnRJZGVudGlmaWVydHJlc2lkZW50X3Bvc3RhbF9jb2RlbGVsZW1lbnRWYWx1ZWU2NDEzM9gYWF-kaGRpZ2VzdElEAGZyYW5kb21QeVoB8I5BSgsvMvSFktXxSXFlbGVtZW50SWRlbnRpZmllcm9yZXNpZGVudF9zdHJlZXRsZWxlbWVudFZhbHVlbEZPUlRVTkFHQVRBTtgYWFykaGRpZ2VzdElEGB1mcmFuZG9tUPZqEH9sCb0LsU7Q1r6NY9pxZWxlbWVudElkZW50aWZpZXJ1cmVzaWRlbnRfaG91c2VfbnVtYmVybGVsZW1lbnRWYWx1ZWIxMtgYWEukaGRpZ2VzdElEGBxmcmFuZG9tUECs5kRT8jGbvlJFfN9PzHVxZWxlbWVudElkZW50aWZpZXJmZ2VuZGVybGVsZW1lbnRWYWx1ZQHYGFhRpGhkaWdlc3RJRBRmcmFuZG9tUJAnJk_8qaLhZyz16KD1mm5xZWxlbWVudElkZW50aWZpZXJrbmF0aW9uYWxpdHlsZWxlbWVudFZhbHVlYlNF2BhYZqRoZGlnZXN0SUQQZnJhbmRvbVDnNyg3BVSwxg7oPIz_ex1lcWVsZW1lbnRJZGVudGlmaWVybWlzc3VhbmNlX2RhdGVsZWxlbWVudFZhbHVlwHQyMDA5LTAxLTAxVDAwOjAwOjAwWtgYWGSkaGRpZ2VzdElEEWZyYW5kb21QiLdvkB7-ePM8bQhtrw03P3FlbGVtZW50SWRlbnRpZmllcmtleHBpcnlfZGF0ZWxlbGVtZW50VmFsdWXAdDIwNTAtMDMtMzBUMDA6MDA6MDBa2BhYWaRoZGlnZXN0SUQYH2ZyYW5kb21Q88ycru5RpECbD5sO1xF5JXFlbGVtZW50SWRlbnRpZmllcnFpc3N1aW5nX2F1dGhvcml0eWxlbGVtZW50VmFsdWVjVVRP2BhYXKRoZGlnZXN0SUQHZnJhbmRvbVD5ok_CSVzYG_zxW4dCLYgRcWVsZW1lbnRJZGVudGlmaWVyb2RvY3VtZW50X251bWJlcmxlbGVtZW50VmFsdWVpMTExMTExMTE02BhYY6RoZGlnZXN0SUQWZnJhbmRvbVADONLlWKTDtc-PYFNRXifWcWVsZW1lbnRJZGVudGlmaWVydWFkbWluaXN0cmF0aXZlX251bWJlcmxlbGVtZW50VmFsdWVqOTAxMDE2NzQ2NNgYWFWkaGRpZ2VzdElEAWZyYW5kb21QnEwHop2wmETQk18jh7jsMnFlbGVtZW50SWRlbnRpZmllcm9pc3N1aW5nX2NvdW50cnlsZWxlbWVudFZhbHVlYlNF2BhYXKRoZGlnZXN0SUQJZnJhbmRvbVCakKMOPVNIi1XdtiS3RAEGcWVsZW1lbnRJZGVudGlmaWVydGlzc3VpbmdfanVyaXNkaWN0aW9ubGVsZW1lbnRWYWx1ZWRTRS1Jamlzc3VlckF1dGiEQ6EBJqEYIVkChTCCAoEwggImoAMCAQICCRZK5ZkC3AUQZDAKBggqhkjOPQQDAjBYMQswCQYDVQQGEwJCRTEcMBoGA1UEChMTRXVyb3BlYW4gQ29tbWlzc2lvbjErMCkGA1UEAxMiRVUgRGlnaXRhbCBJZGVudGl0eSBXYWxsZXQgVGVzdCBDQTAeFw0yMzA1MzAxMjMwMDBaFw0yNDA1MjkxMjMwMDBaMGUxCzAJBgNVBAYTAkJFMRwwGgYDVQQKExNFdXJvcGVhbiBDb21taXNzaW9uMTgwNgYDVQQDEy9FVSBEaWdpdGFsIElkZW50aXR5IFdhbGxldCBUZXN0IERvY3VtZW50IFNpZ25lcjBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABHyTE_TBpKpOsLPraBGkmU5Z3meZZDHC864IjrehBhy2WL2MORJsGVl6yQ35nQeNPvORO6NL2yy8aYfQJ-mvnfyjgcswgcgwHQYDVR0OBBYEFNGksSQ5MvtFcnKZSPJSfZVYp00tMB8GA1UdIwQYMBaAFDKR6w4cAR0UDnZPbE_qTJY42vsEMA4GA1UdDwEB_wQEAwIHgDASBgNVHSUECzAJBgcogYxdBQECMB8GA1UdEgQYMBaGFGh0dHA6Ly93d3cuZXVkaXcuZGV2MEEGA1UdHwQ6MDgwNqA0oDKGMGh0dHBzOi8vc3RhdGljLmV1ZGl3LmRldi9wa2kvY3JsL2lzbzE4MDEzLWRzLmNybDAKBggqhkjOPQQDAgNJADBGAiEA3l-Y5x72V1ISa_LEuE_e34HSQ8pXsVvTGKq58evrP30CIQD-Ivcya0tXWP8W_obTOo2NKYghadoEm1peLIBqsUcISFkF9tgYWQXxpmd2ZXJzaW9uYzEuMG9kaWdlc3RBbGdvcml0aG1nU0hBLTI1Nmdkb2NUeXBleBhldS5ldXJvcGEuZWMuZXVkaXcucGlkLjFsdmFsdWVEaWdlc3RzoXgYZXUuZXVyb3BhLmVjLmV1ZGl3LnBpZC4xuCIAWCD7W3-dBVCt3o3cDIYNaDkM1DS45diRQiz4K3YWFeSWFQFYIKJtyxTxqSQabkLeNzlU47KF9EGDkj3V5rH0e9Q1-lsEAlggUNP1_0Zc8kTYS8QL6z4oQomUBgH6O-shAj5iyZ8bCAUDWCCuQigYwxLYp4LVGOTGUs1qnnTU1tvLMcC98b_VigL_swRYIAfS34ulNQZvT0E22diN-NuIae52N9SzZXe-xlMp5C1vBVggAkEv95LMRoGJyOteiPfAU8_PThHsdmzt0Xyt6JoEsZoGWCDXqUDv-8ZAiWDnaafykV_T_01Lp1riTPapZNU5zI40wgdYIFLiTVYD7-VcrqniT04k_Q5H-hN6tYOEhk9hsTo11doKCFggxZXKN--iXILeaopizcn63992DEtS0KUxuEY6G7tSqB0JWCA7b-nAaWHc3AjTMtCTo178-Fq1bUrtCL39os-grqpa7QpYIIiHGCd2RZ3WPvhk7IIs-dxoWlc1v8SStjYi7uIzo__2C1ggmJ0y-WZefrnjeKUSoJgp48nLSgUGpKTllcz75lcj8TwMWCAteXytlADF9YQcRhXnbHZ4hU-3Fn5V-Yfbmo4A04Cq0Q1YIMQKhcyPGZizCKvulDn8dUumLukLSmAqeno7xdvBPYlQDlggh5HapQ08xo6J5hPpvxtKamGU5Q2yNAc_dwLuyZ9vZ7UPWCBquMRplGPA8YtUtWPsWswGMb-G8N9ZDVBEtMU96CJN0hBYIJLyfEQ3cYpDg7P6qDlmAO0zG7uQB_RVzHsPRXOtJZrTEVggJujmxDXHoF1vp6Os2d_7Y5lyuo0JVrxd78aAU8OnLOgSWCA-9Wlkv2ooawcektfcHHta08eB06bKB5ckORg3_6Gt6RNYIOrbnoAvuGPILZb4oU9OXuFwhrmN24sUHQHaJM1wPo6CFFgg-YDc24tVJZ1aBiVZrIryUkklnztL_DjkSW_0qLuDjsUVWCAxr4Uys8fXbxeTvKfofNqpxTmo7mwCTygExduL5M38MBZYIJXXKk1Az7gaKrhY_Ahsz_n8pDhDY1Lfmqm0QS4JoaF8F1ggl-1ikQmy375eg5ya4CmO4iUZRb7iWm1zeI6zhUhM7lEYGFggMJUtUrlwL9MPNFtEb0Hnz5SqB2qlQrrQj3ZnQM-mGmgYGVggWl3f3p6lfBFnbu2daWLJm39SoGElzlfavTOx3F_3E74YGlggvdD45pF51Cy3yiZ2_nSYqVqJyHT8QNToZG6TNzWEwHAYG1gg8ANMye6A3IzWp2c8WNSRM0Y2Mh1mjIRPw0HKx3isb5gYHFggNDf7Ax-w_4phWXsVvPRk7P7ofgHjKkUBT78O75cwXIkYHVggDXc6YZNFdRk46rqUsKlvVmMzpBHnqA2XZJmqaugJvzcYHlggXH0jeH3-U3jTzR37HDW-jWK6ouF-G5NNPuJmuj6hpQEYH1ggG0an4SprpVwTUMcScwaAZg0Le3EUMRXs2kXZEMi1YiMYIFggI1FLAHl0o8wOVSfw9YJXN8sMeV9UlVg6hpK5ftfTO7EYIVggplIunh7mRw7jAxRznT1H65zgNia37L_reyAW-NqDRPBtZGV2aWNlS2V5SW5mb6FpZGV2aWNlS2V5pAECIAEhWCABzyHIg6bpG-9oGY8eJKRliIpIZAkYu6kgXPmqWEat-yJYIINkaU-HyQEVbtaFN1tc2jlxpe-HF1qvKIpq_oZyZ9gtbHZhbGlkaXR5SW5mb6Nmc2lnbmVkwHQyMDIzLTA5LTA1VDEyOjIyOjUwWml2YWxpZEZyb23AdDIwMjMtMDktMDVUMTI6MjI6NTBaanZhbGlkVW50aWzAdDIwMjQtMDktMDVUMTI6MjI6NTBaWEBrha1cC82HzHS162luGdghMM6OKLzqSaFZk_n1sxiHVkt3Hg9p8N5nE0lHUeUSoGTPzxfLRy-iX98Hd2YRSoybbGRldmljZVNpZ25lZKJqbmFtZVNwYWNlc9gYQaBqZGV2aWNlQXV0aKFvZGV2aWNlU2lnbmF0dXJlhEOhASag9lhA2m2BqQWbJmPL5xogKMm0Vw7_kakFqEStS3nGjaWZmTXmUzuVTLNw8pHw-0rcgd4oPIwpFwHyFYcS5AFaDLujPmZzdGF0dXMA"
  
  static let cbor = "o2d2ZXJzaW9uYzEuMGlkb2N1bWVudHOBo2dkb2NUeXBld2V1LmV1cm9wYS5lYy5ldWRpLnBpZC4xbGlzc3VlclNpZ25lZKJqbmFtZVNwYWNlc6F3ZXUuZXVyb3BhLmVjLmV1ZGkucGlkLjGW2BhYU6RoZGlnZXN0SUQAZnJhbmRvbVBfoWcT7osQmJ70gHb0nxk1cWVsZW1lbnRJZGVudGlmaWVya2ZhbWlseV9uYW1lbGVsZW1lbnRWYWx1ZWROZWFs2BhYU6RoZGlnZXN0SUQBZnJhbmRvbVDXyww2j1xAM7Vw7ecFGfM9cWVsZW1lbnRJZGVudGlmaWVyamdpdmVuX25hbWVsZWxlbWVudFZhbHVlZVR5bGVy2BhYW6RoZGlnZXN0SUQCZnJhbmRvbVBJk3x4QyG0NnnWKeRIsgvNcWVsZW1lbnRJZGVudGlmaWVyamJpcnRoX2RhdGVsZWxlbWVudFZhbHVl2QPsajE5NTUtMDQtMTLYGFhepGhkaWdlc3RJRANmcmFuZG9tUKlupy3GKYGDAXLBItFByQRxZWxlbWVudElkZW50aWZpZXJrYmlydGhfcGxhY2VsZWxlbWVudFZhbHVlbzEwMSBUcmF1bmVyLCBBVNgYWFKkaGRpZ2VzdElEBGZyYW5kb21QTAx4J9lkoHJfvyLlhhb5EXFlbGVtZW50SWRlbnRpZmllcmtuYXRpb25hbGl0eWxlbGVtZW50VmFsdWWBYkFU2BhYVqRoZGlnZXN0SUQFZnJhbmRvbVC66sWEZqas-SfJM5i46tpEcWVsZW1lbnRJZGVudGlmaWVycHJlc2lkZW50X2NvdW50cnlsZWxlbWVudFZhbHVlYkFU2BhYX6RoZGlnZXN0SUQGZnJhbmRvbVCUgMB4TDlM59hQwucUi4r9cWVsZW1lbnRJZGVudGlmaWVybnJlc2lkZW50X3N0YXRlbGVsZW1lbnRWYWx1ZW1Mb3dlciBBdXN0cmlh2BhYY6RoZGlnZXN0SUQHZnJhbmRvbVDwMd05lB6aW9S9y8uMcPBdcWVsZW1lbnRJZGVudGlmaWVybXJlc2lkZW50X2NpdHlsZWxlbWVudFZhbHVlckdlbWVpbmRlIEJpYmVyYmFjaNgYWFykaGRpZ2VzdElECGZyYW5kb21QVet_dZBfz40MxFxf7VR2BHFlbGVtZW50SWRlbnRpZmllcnRyZXNpZGVudF9wb3N0YWxfY29kZWxlbGVtZW50VmFsdWVkMzMzMdgYWFqkaGRpZ2VzdElECWZyYW5kb21QxfAy_ueE1AMf1pp1G3qey3FlbGVtZW50SWRlbnRpZmllcm9yZXNpZGVudF9zdHJlZXRsZWxlbWVudFZhbHVlZ1RyYXVuZXLYGFhdpGhkaWdlc3RJRApmcmFuZG9tUKv_nzHbjxXTXHPRguACHhxxZWxlbWVudElkZW50aWZpZXJ1cmVzaWRlbnRfaG91c2VfbnVtYmVybGVsZW1lbnRWYWx1ZWQxMDEg2BhYWaRoZGlnZXN0SUQLZnJhbmRvbVBwytQucfMjf_ssmxLhe8uWcWVsZW1lbnRJZGVudGlmaWVycWZhbWlseV9uYW1lX2JpcnRobGVsZW1lbnRWYWx1ZWROZWFs2BhYWaRoZGlnZXN0SUQMZnJhbmRvbVABQ9YYcPMq-Ul9bdF8KgLdcWVsZW1lbnRJZGVudGlmaWVycGdpdmVuX25hbWVfYmlydGhsZWxlbWVudFZhbHVlZVR5bGVy2BhYR6RoZGlnZXN0SUQNZnJhbmRvbVBekpi0PcEX6m51NYC_NGQCcWVsZW1lbnRJZGVudGlmaWVyY3NleGxlbGVtZW50VmFsdWUB2BhYZ6RoZGlnZXN0SUQOZnJhbmRvbVC6wUYHsO2kNY_IjW4L-LjRcWVsZW1lbnRJZGVudGlmaWVybWVtYWlsX2FkZHJlc3NsZWxlbWVudFZhbHVldnR5bGVyLm5lYWxAZXhhbXBsZS5jb23YGFiIpGhkaWdlc3RJRA9mcmFuZG9tUME8UCXQVA3o3o0SjZQbWIFxZWxlbWVudElkZW50aWZpZXJ4HnBlcnNvbmFsX2FkbWluaXN0cmF0aXZlX251bWJlcmxlbGVtZW50VmFsdWV4JDdlNDQzYjI0LTgxMjQtNDI5My1hYmEyLTNlYWE4Y2E0OTM1MNgYWFykaGRpZ2VzdElEEGZyYW5kb21Q0zLqqj0_9Y2Ukn0UehRFhHFlbGVtZW50SWRlbnRpZmllcmtleHBpcnlfZGF0ZWxlbGVtZW50VmFsdWXZA-xqMjAyNi0wMS0yNdgYWHGkaGRpZ2VzdElEEWZyYW5kb21QPOK6o2rILXMcNgjfeqULm3FlbGVtZW50SWRlbnRpZmllcnFpc3N1aW5nX2F1dGhvcml0eWxlbGVtZW50VmFsdWV4G0dSIEFkbWluaXN0cmF0aXZlIGF1dGhvcml0edgYWFWkaGRpZ2VzdElEEmZyYW5kb21QZWYUO-M50RzYoPMfs27zFHFlbGVtZW50SWRlbnRpZmllcm9pc3N1aW5nX2NvdW50cnlsZWxlbWVudFZhbHVlYkdS2BhYeKRoZGlnZXN0SUQTZnJhbmRvbVBrNn5Q4s71ODrY3JZ0Baz6cWVsZW1lbnRJZGVudGlmaWVyb2RvY3VtZW50X251bWJlcmxlbGVtZW50VmFsdWV4JGFmNjcwMzk0LTgzMmUtNGQzMS04Y2Q2LTQ3NjkyNjBkN2Y0M9gYWFykaGRpZ2VzdElEFGZyYW5kb21Q1S7axhORE33CMrRjn_PbknFlbGVtZW50SWRlbnRpZmllcnRpc3N1aW5nX2p1cmlzZGljdGlvbmxlbGVtZW50VmFsdWVkR1ItSdgYWF6kaGRpZ2VzdElEFWZyYW5kb21QZAlseaOGYEnpGtz9Gia3X3FlbGVtZW50SWRlbnRpZmllcm1pc3N1YW5jZV9kYXRlbGVsZW1lbnRWYWx1ZdkD7GoyMDI1LTEwLTE3amlzc3VlckF1dGiEQ6EBJqEYIVkC7zCCAuswggKRoAMCAQICFG1_J22Ei0b8tdJijfoXwla__HAXMAoGCCqGSM49BAMCMFwxHjAcBgNVBAMMFVBJRCBJc3N1ZXIgQ0EgLSBVVCAwMjEtMCsGA1UECgwkRVVESSBXYWxsZXQgUmVmZXJlbmNlIEltcGxlbWVudGF0aW9uMQswCQYDVQQGEwJVVDAeFw0yNTA0MTAxNDI1NDBaFw0yNjA3MDQxNDI1MzlaMFIxFDASBgNVBAMMC1BJRCBEUyAtIDAzMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEq8Wdd8C4_51Lhnm2EZjztKu6UZNcdUo66i077UBaUHMvU8BQnIInvwQQto_yqS3Aq_qI-LcmQKH5rx3WkxMWwaOCATkwggE1MB8GA1UdIwQYMBaAFGLHlEcovQ-iFiCnmsJJlETxAdPHMCcGA1UdEQQgMB6CHGRldi5pc3N1ZXItYmFja2VuZC5ldWRpdy5kZXYwFgYDVR0lAQH_BAwwCgYIK4ECAgAAAQIwQwYDVR0fBDwwOjA4oDagNIYyaHR0cHM6Ly9wcmVwcm9kLnBraS5ldWRpdy5kZXYvY3JsL3BpZF9DQV9VVF8wMi5jcmwwHQYDVR0OBBYEFHLNysqosx4LV0Xt9p-iQSRwH2i2MA4GA1UdDwEB_wQEAwIHgDBdBgNVHRIEVjBUhlJodHRwczovL2dpdGh1Yi5jb20vZXUtZGlnaXRhbC1pZGVudGl0eS13YWxsZXQvYXJjaGl0ZWN0dXJlLWFuZC1yZWZlcmVuY2UtZnJhbWV3b3JrMAoGCCqGSM49BAMCA0gAMEUCIE1WZ3IQ_kI6ud17NKHNO8t8xupAFxZCfmSs5VRttrAvAiEA7QzEKtEJv30OaK640U-FwftCW-sRT8V_UJFUWjMvyIhZBGTYGFkEX6ZndmVyc2lvbmMxLjBvZGlnZXN0QWxnb3JpdGhtZ1NIQS0yNTZsdmFsdWVEaWdlc3RzoXdldS5ldXJvcGEuZWMuZXVkaS5waWQuMbYAWCCRbjD-oxastWurlA4GkkNx67dNMc6r22J0Rp_DU06PBQFYIFwoNa8nWktDnUkM-8SxPzWomLziCa_0cDNbZB81ZlziAlgg2WF00qeIEn_7x9IQSN1md6tdGOdKnssGYySzdSbZnOQDWCASjCfyUgMP1UpQAoT5SzbaIpEVK5ZRmikMqK3oCt3wKQRYIAiJgCXh_OGkpt4SrCd5nxzEtSLepCUBerfqA8WuMfn6BVgg_guRuBPPVbUYSHMlbEq4hDFMrDOOCsYiMIv59T7ynLgGWCBQgzKb7hONiIH-ejPLVqP5uOIvy3vq7ArmhmQ3ZoDvrAdYIEVnmIbgS8hDys_zDOjXK4cvthG41OT81lt5dpQ584WYCFggRONuSESzLAUnI0Hfm6IeUKqLnf3AoLfw1xOh_pgyoQMJWCBiaYDi5VHF6kbVVDdS9rVGiaTfc3SksDQvhnnjT_9OawpYINbQOwmGh-tj2LX2GIyHA59Dn0IWZ1eFoSwsXCqxeqbRC1ggaNdNOIjB8NWa8JjDvwdcRCm5btcl1AHjYAvhoo6SpHsMWCA58LNAPwUzdBTgmlaWKx4Txpnd-Ydflcibt_U6CsdmGA1YIBDOKTBMH9n2xSoU_UufvOZOnXQkIPSM9XYGMIezV1iCDlggJLYfJlAz0B8MvR6M4vQR_uNAExkEHo2hzfauaBKXzE0PWCCfwO1HbMrqHq9zJNjyNw9IhmjpF8Ddgdbch9V7UwrVmhBYIJlEyNMFMtHjZm95Wbo-vCKU3koVI77SYfrg-ztZXqdUEVggWR8FnTz4RdKEz6Ng9DFdcqKuWM7bKMUYqHwWbRLL_BkSWCBEJjERDCvyHoXfJHZmzP3F90Sf_PApKIoi-RwpVXL4dBNYID_wjiUKrizPUsrKGOWmJxpnoYQcCrFI1-VW2eAXCGgLFFggvL3XRfz7zZGqwaFxJiZSQjAaibielXloHqeklPTK7YYVWCDbBjcpV9pRnnA4t9DVGfo9kLECB6fTCAdeI5cl_t7dFW1kZXZpY2VLZXlJbmZvoWlkZXZpY2VLZXmkAQIgASFYIFbVA3fcnDlrVsqRgLuYFg2Ffsf2OmsB-4lxole5s_ORIlggr7o_bQ-TG4d22mtsrXGucTmkp1t2Z-Ms30JlN0c_CyRnZG9jVHlwZXdldS5ldXJvcGEuZWMuZXVkaS5waWQuMWx2YWxpZGl0eUluZm-jZnNpZ25lZMB4HjIwMjUtMTAtMTdUMTE6MzE6MTQuMzIxMDE4NDM5Wml2YWxpZEZyb23AeB4yMDI1LTEwLTE3VDExOjMxOjE0LjMyMTAxODQzOVpqdmFsaWRVbnRpbMB4HjIwMjUtMTEtMTZUMTE6MzE6MTQuMzIxMDE4NDM5WlhAD4cIaC4_rLPKWj1F4mMtgyqV-0yJJQdm8HVI1iGHR1wkelUXT_9Opwdg2SKoypVC87V-iF2dT0dBCng-KDK1RmxkZXZpY2VTaWduZWSiam5hbWVTcGFjZXPYGEGgamRldmljZUF1dGihb2RldmljZVNpZ25hdHVyZYRDoQEmoRghgEGgWEAjDrEBttTd9af0VHyxKQKS2s5GDEjrJna4rg86hprQx3Nc26QXjL9GXoncXrxkMlR8PUsHFPcBO3obe8qRCLuGZnN0YXR1cwA"
  
  static let invalidCbor = "o2d2ZXJzaW9uYzEuMGlkb2N1bWVudHOBo2dkb2NUeXBld2V1LmV1cm9wYS5lYy5ldWRpLnBpZC4xbGlzc3VlclNpZ25lZKJqbmFtZVNwYWNlc6F3ZXUuZXVyb3BhLmVjLmV1ZGkucGlkLjGYJNgYWIWkZnJhbmRvbVhA-Godwkrhr93XsAY_iCz8r810ldy9ZHFK9Y0tdcDjBCk5DGVCCzwYvtDFrhLRSrluKZcyYLxMxi4N7L6lVnLdr2hkaWdlc3RJRBhCbGVsZW1lbnRWYWx1ZWR0ZXN0cWVsZW1lbnRJZGVudGlmaWVya2ZhbWlseV9uYW1l2BhYgKRmcmFuZG9tWECHgQqd3lllV_WGUfIJoouVu6JBtyQ7mhYrSXxY_I4tt_zyQMIEBfrceh8_4Jpn3C14mVs-6WYYyJ2L_XYfUiI1aGRpZ2VzdElEAGxlbGVtZW50VmFsdWVhZnFlbGVtZW50SWRlbnRpZmllcmpnaXZlbl9uYW1l2BhYjKRmcmFuZG9tWEBU01ICTv3UO50-exA5BmDZsFZTva_J3u2L3LdVEqv1ym104S0vUM4gZmxZxQq7woAZsqEi6mYU_NWZTReuexIlaGRpZ2VzdElEF2xlbGVtZW50VmFsdWXZA-xqMjAyNS0wMS0wMXFlbGVtZW50SWRlbnRpZmllcmpiaXJ0aF9kYXRl2BhYi6RmcmFuZG9tWED8Sr7x9zkNj4Xr8wWsIudqxbkipgntcNmfR2sbjGfMFFhHJz2so1HGE_5MP9bI6KcJCgOUE5D_PyXb3HbyN8dOaGRpZ2VzdElEGCZsZWxlbWVudFZhbHVlZHRlc3RxZWxlbWVudElkZW50aWZpZXJxZmFtaWx5X25hbWVfYmlydGjYGFiGpGZyYW5kb21YQG7f5XVPqSOXGIssvnXrLp0qBQq-SK1lRG994CY2UXfn9CY9vnrKUO0oY2o3_-maGpxfsMnYZZ44usk30YVg6JxoZGlnZXN0SUQGbGVsZW1lbnRWYWx1ZWFmcWVsZW1lbnRJZGVudGlmaWVycGdpdmVuX25hbWVfYmlydGjYGFiHpGZyYW5kb21YQPPfjzt9PQkGBGoArMgXESK7GMtcBXcaO1M8uhrPCsOhxtCGclxFuVrVhpja8jDqUb9LPpsK8gvEQ1PU-jovnOdoZGlnZXN0SUQYKmxlbGVtZW50VmFsdWVmU1dFREVOcWVsZW1lbnRJZGVudGlmaWVya2JpcnRoX3BsYWNl2BhYhaRmcmFuZG9tWEAEarW6BkP4XdId78TgifnBOtbZ0BUKFo9V9mc0QMiaPFWf5stvPQdu7g4zl8_8MTvWb02pM9VXTEYldLzS0xG-aGRpZ2VzdElEGENsZWxlbWVudFZhbHVlYlNFcWVsZW1lbnRJZGVudGlmaWVybWJpcnRoX2NvdW50cnnYGFiDpGZyYW5kb21YQJx-ySnJkm785KrEhRSGJ8eIYOhoTWnUxaUUDndcSvOeBSy9vSUv9H9gHC4P9QryFFCUCl8oFzKo0JY5zlsnuVhoZGlnZXN0SUQYNWxlbGVtZW50VmFsdWViU0VxZWxlbWVudElkZW50aWZpZXJrYmlydGhfc3RhdGXYGFiLpGZyYW5kb21YQPyqvO42TfFKm6D11i6-gBUCeI-x5PenC2CiYEp2SaYnDMmydvbztnZMtNmjvDMUd6l-u5Wi6JoL1rZUKDSllMhoZGlnZXN0SUQYGmxlbGVtZW50VmFsdWVrS0FUUklORUhPTE1xZWxlbWVudElkZW50aWZpZXJqYmlydGhfY2l0edgYWRWFpGZyYW5kb21YQPT9DDI3I80JgqbdAV7X_e1x2ZpJ9MA3hFT6QUc_eO6v84wRn6GytqWQ_w5KfouU02N0qCWULuFu7ypscyooxENoZGlnZXN0SUQYL2xlbGVtZW50VmFsdWVZFQWJUE5HDQoaCgAAAA1JSERSAAAAlgAAAJYIBAAAAJYIuWkAAA0EaUNDUGtDR0NvbG9yU3BhY2VHZW5lcmljR3JheUdhbW1hMl8yAABYhaVXB1yT1xa_38gAkrCnjLCRZUCBADIiM4DsIbiISSCBEGIGAuJCihWsWxw4KiqKWlwVgTpRi1bqxq0Paqmg1GItLqy-mwQQq-177_e-_O53_98959xzzj3nnnsDgO5GjkQiQgEAeWK5NCKRlT4pPYNOugfIwBhoA3egzeHKJKz4-BjIAsT5Yj745HlxAyDK_pqbcq5P6f_4EHh8GRf2J2Er4sm4eQAg4wEgm3ElUjkAGpPguO0suUSJSyA2yE1ODIF4OeShDMoqH6sIvpgvFXLpEVJOET2Ck5fHoXu6e9LjpflZQtFnrP5_nzyRYlg3bBRZblI07N2h_WU8TqgS-0F8kMsJS4KYCXFvgTA1FuJgAFA7iXxCIsRREPMUuSksiF0hrs-ShqdAHAjxHYEiUonHAYCZFAuS0yA2gzgmNz9aKWsDcZZ4RmycWhf2JVcWkgGxE8QtAj5bGTM7iB9L8xOVPM4A4DQePzQMYmgHzhTK2cmDuFxWkBSmthO_XiwIiVXrIlByOFHxEDtA7MAXRSSq5yHESOTxyjnhN6FALIqNUftFOMeXqfyF30SyXJAcCbEnxMlyaXKi2h5ieZYwnA1xOMS7BdLIRLW_xD6JSJVncE1I7hxpWIR6TUiFUkViitpH0na-OEU5P8wR0gOQinAAH-SDGfDNBWLQCehABoSgQIWyAQfkwUaHFrjCFgG5xLBJIYcM5Ko4pKBrmD4koZRxAxJIywdZkFcEJYfG6YAHZ1BLKmfJh035pZy5WzXGHdToDluI5Q6ggF8C0AvpAogmgg7VSCG0MA_2IXBUAWnZEI_UopaPV1mrtoE-aH_PoJZ8lS2cYbkPtoVAuhgUwxHZkG-4Mc7Ax8Lmj8fgAThDJSWFHEXATTU-XjU2pPWD50rfeoa1zoS2jvR-5IoNreIpKCWH3yLooXhwfWTQmrdQJndQ-i9-LjdTOEkkVUsT2NNq1SOl0ulC7qVlfa0lR00A_caSk-cBfa9O07lhG-nteOOUa5TWkn-I6qe2fRzVuJF5o8ok3id5A3URrhIuEx4QrgM67H8mtBO6IbpLuAd_t4ft-RAD9doM5YTaLi6CDdvAgppFKmoebEIVj2w4HgqI5fCdpZJ2-0ssIj7xaCQ9f1h7Nmz5f7VhMGP4Kv2cz67P_7JDRqxklni5mUQyrbZkgC9Rr4cydvxFsS9iQakrYz-jl7GdsZfxnPHgQ_wYNxm_MtoZWyHlCbYKO4wdw5qwZqwN0OFXM3YKa1KhvdhR-DvwNzsi-zM7Qplh3MEdoKTKB3Nw5F4Z6TNrRDSU_ENrmPM3-T0yh5Rr-d9ZNHKejysI_8MupdnSPGgkmjPNi8aiITRr-POkBUNkS7OhxdCMITWS5kgLpY0akXfqiIkGM0j4UT1QW5wOqUOZJlZVIw7kVHJwBv39q4_0j7xUeiYcmRsIFeaGcEQN-Vzton-011KgrBDMUsnLVNVBrJKTfJTfMlXVgiPIZFUMP2Mb0Y_oSAwjOn7QQwwlRhLDYe-hHCeOIUZB7Kvkwi1xD5wNq1scoOMs3AsPHsTqijdU81RRxYMgNRAPxZnKGvnRTuD-R09H7kJ415DzC-XKi0FIvqRIKswWyOkseDPi09lirrsr3ZPhAU9E5T1LfX14nqC6PyFGbVyFtEA9hitfBKAJ72AGwBRYAlt4qrtBXT7AH56zYfCMjAPJMLLToHUCaI0Urm0JWADKQSVYDtaADWAL2A7qQD04CI6Ao7Aqfw8ugMugHdyFJ1AXeAL6wAswgCAICaEi-ogpYoXYIy6IJ8JEApEwJAZJRNKRTCQbESMKpARZiFQiK5ENyFakDjmANCGnkPPIFeQ20on0IL8jb1AMpaAGqAXqgI5BmSgLjUaT0aloNjoTLUbL0KXoOrQG3Ys2oKfQC2g72oE-QfsxgGlhRpg15oYxsRAsDsvAsjApNherwKqwGqweVoFW7BrWgfVir3Eiro_TcTcYm0g8BefiM_G5-BJ8A74Lb8DP4NfwTrwPf0egEswJLgQ_ApswiZBNmEUoJ1QRagmHCWdh1e4ivCASiUYwL3xgvqQTc4iziUuIm4j7iCeJV4gPif0kEsmU5EIKIMWROCQ5qZy0nrSXdIJ0ldRFekXWIluRPcnh5AyymFxKriLvJh8nXyU_Ig9o6GjYa_hpxGnwNIo0lmls12jWuKTRpTGgqavpqBmgmayZo7lAc51mveZZzXuaz7W0tGy0fLUStIRa87XWae3XOqfVqfWaokdxpoRQplAUlKWUnZSTlNuU51Qq1YEaTM2gyqlLqXXU09QH1Fc0fZo7jU3j0ebRqmkNtKu0p9oa2vbaLO1p2sXaVdqHtC9p9-po6DjohOhwdObqVOs06dzU6dfV1_XQjdPN012iu1v3vG63HknPQS9Mj6dXprdN77TeQ31M31Y_RJ-rv1B_u_5Z_S4DooGjAdsgx6DS4BuDiwZ9hnqG4wxTDQsNqw2PGXYYYUYORmwjkdEyo4NGN4zeGFsYs4z5xouN642vGr80GWUSbMI3qTDZZ9Ju8saUbhpmmmu6wvSI6X0z3MzZLMFsltlms7NmvaMMRvmP4o6qGHVw1B1z1NzZPNF8tvk28zbzfgtLiwgLicV6i9MWvZZGlsGWOZarLY9b9ljpWwVaCa1WW52wekw3pLPoIvo6-hl6n7W5daS1wnqr9UXrARtHmxSbUpt9NvdtNW2Ztlm2q21bbPvsrOwm2pXY7bG7Y69hz7QX2K-1b7V_6eDokOawyOGIQ7ejiSPbsdhxj-M9J6pTkNNMpxqn66OJo5mjc0dvGn3ZGXX2chY4VztfckFdvF2ELptcrrgSXH1dxa41rjfdKG4stwK3PW6d7kbuMe6l7kfcn46xG5MxZsWY1jHvGF4METzf7nroeUR5lHo0e_zu6ezJ9az2vD6WOjZ87LyxjWOfjXMZxx-3edwtL32viV6LvFq8_vT28ZZ613v3-Nj5ZPps9LnJNGDGM5cwz_kSfCf4zvM96vvaz9tP7nfQ7zd_N_9c_93-3eMdx_PHbx__MMAmgBOwNaAjkB6YGfh1YEeQdRAnqCbop2DbYF5wbfAj1mhWDmsv6-kExgTphMMTXob4hcwJORmKhUaEVoReDNMLSwnbEPYg3CY8O3xPeF-EV8TsiJORhMjoyBWRN9kWbC67jt0X5RM1J-pMNCU6KXpD9E8xzjHSmOaJ6MSoiasm3ou1jxXHHokDcey4VXH34x3jZ8Z_l0BMiE-oTvgl0SOxJLE1ST9petLupBfJE5KXJd9NcUpRpLSkaqdOSa1LfZkWmrYyrWPSmElzJl1IN0sXpjdmkDJSM2oz-ieHTV4zuWuK15TyKTemOk4tnHp-mtk00bRj07Wnc6YfyiRkpmXuznzLiePUcPpnsGdsnNHHDeGu5T7hBfNW83r4AfyV_EdZAVkrs7qzA7JXZfcIggRVgl5hiHCD8FlOZM6WnJe5cbk7c9-L0kT78sh5mXlNYj1xrvhMvmV-Yf4ViYukXNIx02_mmpl90mhprQyRTZU1yg3gn9I2hZPiC0VnQWBBdcGrWamzDhXqFooL24qcixYXPSoOL94xG5_Nnd1SYl2yoKRzDmvO1rnI3BlzW-bZziub1zU_Yv6uBZoLchf8WMooXVn6x8K0hc1lFmXzyx5-EfHFnnJaubT85iL_RVu-xL8Ufnlx8djF6xe_q-BV_FDJqKyqfLuEu-SHrzy-WvfV-6VZSy8u8162eTlxuXj5jRVBK3at1F1ZvPLhqomrGlbTV1es_mPN9DXnq8ZVbVmruVaxtmNdzLrG9Xbrl69_u0Gwob16QvW-jeYbF298uYm36erm4M31Wyy2VG5587Xw61tbI7Y21DjUVG0jbivY9sv21O2tO5g76mrNaitr_9wp3tmxK3HXmTqfurrd5ruX7UH3KPb07J2y9_I3od801rvVb91ntK9yP9iv2P_4QOaBGwejD7YcYh6q_9b-242H9Q9XNCANRQ19RwRHOhrTG680RTW1NPs3H_7O_budR62PVh8zPLbsuObxsuPvTxSf6D8pOdl7KvvUw5bpLXdPTzp9_UzCmYtno8-e-z78-9OtrNYT5wLOHT3vd77pB-YPRy54X2ho82o7_KPXj4cvel9suORzqfGy7-XmK-OvHL8adPXUtdBr319nX7_QHtt-5UbKjVs3p9zsuMW71X1bdPvZnYI7A3fnw4t9xX2d-1UPzB_U_Gv0v_Z1eHcc6wztbPsp6ae7D7kPn_ws-_ltV9kv1F-qHlk9quv27D7aE95z-fHkx11PJE8Gest_1f1141Onp9_-FvxbW9-kvq5n0mfvf1_y3PT5zj_G_dHSH9__4EXei4GXFa9MX-16zXzd-ibtzaOBWW9Jb9f9OfrP5nfR7-69z3v__t8JD_hiTuRihQAAAHhlWElmTU0AKgAAAAgABQESAAMAAAABAAEAAAEaAAUAAAABAAAASgEbAAUAAAABAAAAUgEoAAMAAAABAAIAAIdpAAQAAAABAAAAWgAAAAAAAADYAAAAAQAAANgAAAABAAKgAgAEAAAAAQAAAJagAwAEAAAAAQAAAJYAAAAADId5AAAAAAlwSFlzAAAhOAAAITgBRZYxYAAAABxpRE9UAAAAAgAAAAAAAABLAAAAKAAAAEsAAABLAAADNKq8lQ8AAAMASURBVHgB7NxPSBRRHAfw7265tWUQEVsUQYfcICPQhT2IBWmnSuhU9OfQIaGDdOgYQlFhCEJQhNTBUxAWRf-DooIouxRkBB2ENAkyCJQQVPJP85DHOK5sRDvvy3d23sLOzM7lx2e-b_fx5s0CcYsFYoFYYI5ACutQjRrkUYdaVGEtKuacjXc9kL04jW68wzBmCl6T6MdzXMZBbCxnqyXY7SF8LuApBLOf9OECcuVHVo3OBXNkWYpt3-NI-XTObbiH6X_I00JwX71uGfmWwVVM_SeUxevxfgoi3PZjpERQs2BjaImmVtrLlM1EKbe3kY4a2Eq8CYXKsL_E8ihxZfAhNCrD9QrLosJVid5QqQzXU6SiwJXE_dCpDFdXFLDOOaEyXPIjrxwmnWENY4NyulL46IzKZOuuMtYJp1SGq1GVK43vzrF6kdDkOumcymSrSREr4U3ameJdv14rYjU6Z7KXpVaP6zoN66IaVgV-0bCGsEiLaweNynTG7VpY56lYZ7Wwwpu9sl_jxbZvlbCSGKUmawKLdbg2U6lM5rbqYDXRsQ7pYLXQsU7pYLXTsS7pYF2jY93UweqmYz3QwXpIx3qkg_WYjvUkxio2ag-eu6ODxe-GQncRb9G7YZtOsrroWM06WPxBaZ0O1nFyssaxVAcrT8aSujOdxBCV64BOrkylZ4hY35Q6ocFaQbh1b4elQr-Ehsq0faRsfVKaUp6lMu89FC7JJW2rHK_Nsp2wwb9aOntZDFKSldch8ivNlfhpCpucv22r_BJ09uopuZrBeh0iv9KdJKxKvwSdPc76rAnNZy0aKMn6qTnK4iw6-uI9hi7YaijJGsAeQStsomCNoV4RK0PBGsUWRaw0BWsaaxSxgHEC12_VPzHoJ2CNaOaKM0XTp4p1g5AsyYdRzAVuI2AJrXEI9oFjBKzOYAk6R4xJmlYdnmClqwnJOhosQenoh3OuXUo8wVqfOcfKBgtQOupwjDWl_L8hhx1jDSolaX6tWcdYL-YXoHSccHw77ErYOH8AAAD__2SoaucAAAPvSURBVO3cW0gVQRgH8H_aOWrQhcqioOhiQVJRdDWzDCTSyi5EmEQ9WNaDSRBR0UNhRAg9RBIEXTSkAsGHkAzKwMAuQg9F-RIUJYqImZZRYHpsVh3aPXs5c2xnPDs7Ow97ds-cHb7ffrvszuwegOdUhwGBpYhnKPy3fUEg1QA28Q-IZws5QrGm8AyF_7YnIySMq5l_OLxbeC8Mq4p3KPy3XyYIqwPL-AfDu4VxuCGA6wNSeAciavu5aOcK1gCPn9qNOyIZ1dy47iHB2JgMS_n4xgHsCsbIgGOOYQYeus51xNyMPGvcPhzL5KExR_LE5dx6Zm5CnjUdLmN1yUNjjCQOc12m0vo0ZhkbkWNpOxpQwgGrQA4efRTJ3C5MuzBb35AMnx9wyCnasViPOBmIaAwFHKk0sjO0Ie_PU9DDGasXq73PpEWQhEbOVFpufcI0b3MFkIM7-C6ASuPqwwucQxrivYYWQDZuc7lxpid1-3k36eE4inleIAuSbCofJSYj4Edcx25Mik20ILahAl2CDjojjP1SH16RS-EMBGIFLRE7UCns3GQP4_RND2pQjEWjS7YV97lfGDghRPtdCzlJ5GOiWLTxyMJ5vIyxg46V7qwIrHgswSEyXvMO_R5lopxtqMVF7MF899mmkrNSKerx0-NElEo_7yRsx8ilswtTEEV4LXAQXh-GyM8tJB3-c1oMccPvImms27qGsSP3OojfEh521lBDa2sQHBnXCZ9BDXFVj6RvrMiXVBrYpWhzK5vcwzulq8zfhUgnQBTTTHT6lkpLg_ZoHjR55GsqjaucNbXyfE-lcaWzcCXis8IiAo0sT-ecVFTDAnsj5VYC2hTWsEBTpCuuQkWlE8hzzq0mXVWZr6XYYnvrhJWmqMIENttz3QqryuYvc61aO6wE_FBYYQIhLLDmyg2rKHPGsMd22RqrUmFZCHy1eso-gG6Lqux7QN6a-8y5lamobASemrFKbarKmzGskYXMD5m8UVi2AiXG3Jrug8Eu1kwy1_tivEvcb6tq_qkf12Tpc6tCYTkK3NVjtTpW9WMuGWP-hQmUK1VRRRQ4TLGOR6xqdPbj0nOKpUZzWHb_Qo0ryXdPNLDQmOsMjlSr3gYzjNWaNu0Zm5vqjMUosAtoZqxqpe2vdaTf9JTCYhQYHMA4zVjZX3kUHm0dfVykWN1IR0iYq_oXqA7gT4Tq4dL-We5FIb0kpfMtMf5CyWjtnFasp0T6-Ry4_RcVoxWge-1W0TOVHop-3gnVZzpE3Y_HLH-5uBKZMVw2IvqyAf9KBnmhLoMcWlpJJ2UdKWlYizXkPetVWIHlWIpU8pqK4JehaLaquRJQAo4CfwHPtZz8zer1bQAAAABJRU5ErkJggnFlbGVtZW50SWRlbnRpZmllcmhwb3J0cmFpdNgYWJekZnJhbmRvbVhAtttVfy9veg-2Lbdfm3YdkWXKyu4HkW85JTkQ4nR0tzDhpVU4THuol4vOj5pLLYcOAQD89SmGyPmWRSNi3pY4CWhkaWdlc3RJRA5sZWxlbWVudFZhbHVlcjQ4MDIgU0hFQk9ZR0FOIEFWRXFlbGVtZW50SWRlbnRpZmllcnByZXNpZGVudF9hZGRyZXNz2BhYh6RmcmFuZG9tWED62s_c4bZpOL4tMd8dvqlGktvojh4VHqWK3WZc9-eT690ozQBSZ93Q5AB_gTNtJNL8oVOgXhNaKTOliAjjDJ15aGRpZ2VzdElEAmxlbGVtZW50VmFsdWViVVNxZWxlbWVudElkZW50aWZpZXJwcmVzaWRlbnRfY291bnRyedgYWIakZnJhbmRvbVhA31pMbBzZR1de-UQeh9qiBOnczcolcypCU0MAx_A3aY5HwD-t44QFW0xHEXCDBL6HA-dLrDVF9qXA1ZPtwdeWgmhkaWdlc3RJRBgebGVsZW1lbnRWYWx1ZWJXSXFlbGVtZW50SWRlbnRpZmllcm5yZXNpZGVudF9zdGF0ZdgYWImkZnJhbmRvbVhAPDTaeu6xzzIkvUp0ZIqdpR5nICRBIa2JpWFC_NJwTbZtnBFwFCm0vaWpjtcwrXfnP2qrUuayNjkKvIPJCQBMf2hkaWdlc3RJRBFsZWxlbWVudFZhbHVlZ01BRElTT05xZWxlbWVudElkZW50aWZpZXJtcmVzaWRlbnRfY2l0edgYWI-kZnJhbmRvbVhAPh9q6pDli_Evo-Kvyj_CoUwRXI8Qr2pokCTX_My2OkP-m4YkcCG8zNviPnAldpdbtKgjA-Navglwrn-uSsLn1WhkaWdlc3RJRBgwbGVsZW1lbnRWYWx1ZWU1MzcwNXFlbGVtZW50SWRlbnRpZmllcnRyZXNpZGVudF9wb3N0YWxfY29kZdgYWJGkZnJhbmRvbVhAWKGDC_yDVqMA0DEOzi9GPrQhcVmTJ-nGaRDqfsAmfNeULYI0Kxd2hcSxJidsnVwpYYe1R4RJR893KRzWpiRh2mhkaWdlc3RJRBhAbGVsZW1lbnRWYWx1ZWxGT1JUVU5BR0FUQU5xZWxlbWVudElkZW50aWZpZXJvcmVzaWRlbnRfc3RyZWV02BhYjKRmcmFuZG9tWEDi-pB1LvBaD7QVIeTJkB4gAxGH0ZnmDDHzEsZci-g8a2ktdVWiFv6N_c4dZDeP_IDyJEna2ddS_RmSRFRrkJKAaGRpZ2VzdElEBWxlbGVtZW50VmFsdWViMTRxZWxlbWVudElkZW50aWZpZXJ1cmVzaWRlbnRfaG91c2VfbnVtYmVy2BhYeaRmcmFuZG9tWEDnOtNzCUIWaMVo8q3p6bL65iDbKM-Dsph2kqFCx06xALJN2lYELNEFYfzyCydM7ghb08jjxhd1qOQQfzIayWT3aGRpZ2VzdElEGCJsZWxlbWVudFZhbHVlAXFlbGVtZW50SWRlbnRpZmllcmNzZXjYGFiEpGZyYW5kb21YQITcO6GU6Qubq0vcwReMPspZbhxvFv8KRHi6seXdwcQx0h6A4B4r1UqN2HiXN9XtUvrze4pyG9-v2zhXKGnVLr5oZGlnZXN0SUQYG2xlbGVtZW50VmFsdWWBYlNFcWVsZW1lbnRJZGVudGlmaWVya25hdGlvbmFsaXR52BhYmKRmcmFuZG9tWEABxhnX4p1Cqa1QL9g46J0K_MRMkq7yroQB3pv0dNKLCQcUiuJ1xzOXCT0sIyJ1oewvk3I9yIIlqXxUNTOJ0De5aGRpZ2VzdElEGCdsZWxlbWVudFZhbHVlwHQyMDA5LTAxLTAxVDAwOjAwOjAwWnFlbGVtZW50SWRlbnRpZmllcm1pc3N1YW5jZV9kYXRl2BhYlaRmcmFuZG9tWEBk6Z049e_2Kvj-HrFLbUdmLxjmPAHDShN36C7C85hHfJbLITMJpuCBEV9fnHiDuFQu0aHLTBJsVx5NyulEym1UaGRpZ2VzdElECGxlbGVtZW50VmFsdWXAdDIwNTAtMDMtMzBUMDA6MDA6MDBacWVsZW1lbnRJZGVudGlmaWVya2V4cGlyeV9kYXRl2BhYiaRmcmFuZG9tWEBl8J57HpF7wx1NuNKnBXU8Rynltzn8_Sg9l4yK4mlm7T-oVWA3AGCZNJSGuf1fHGrOm56UjenZ73u_STHuViNiaGRpZ2VzdElEFWxlbGVtZW50VmFsdWVjVVRPcWVsZW1lbnRJZGVudGlmaWVycWlzc3VpbmdfYXV0aG9yaXR52BhYhqRmcmFuZG9tWECUZXImgA01lAWzxqyGFC1pCJM8HXdCAdzKDWu8lXOlhcbM5mEGCeT1f_KNhDkBAi6VRRSwFDRyAvVMsUzDwmN4aGRpZ2VzdElEBGxlbGVtZW50VmFsdWViU0VxZWxlbWVudElkZW50aWZpZXJvaXNzdWluZ19jb3VudHJ52BhYjaRmcmFuZG9tWEDNf43A1fC0hEXVW5JfXab8CBZUbmI9ajx-5lCqDAgFKFWrpLk2boHI3PaU_Hy_iq77Vl3wUsUAqrrPI5B-y6_3aGRpZ2VzdElEA2xlbGVtZW50VmFsdWVpMTExMTExMTE0cWVsZW1lbnRJZGVudGlmaWVyb2RvY3VtZW50X251bWJlctgYWI2kZnJhbmRvbVhApd7DGCbwsU80HtLDD_TqNX4cmGzvghz5ygVq4oEaatU0D8P4jbXYU8QfdsikgLt2_2v_MUGOvcmSOaMVUJKVjmhkaWdlc3RJRBJsZWxlbWVudFZhbHVlZFNFLUlxZWxlbWVudElkZW50aWZpZXJ0aXNzdWluZ19qdXJpc2RpY3Rpb27YGFiepGZyYW5kb21YQLmMQ_OHbgbuDNPkoAUUmZYmVWuEfWDX8BKncJUI2QUTpt8k18khJyWmMbi0mDc7pgVBVc9xvuXBXxzOps-TMDRoZGlnZXN0SUQLbGVsZW1lbnRWYWx1ZWo5MDEwMTY3NDY0cWVsZW1lbnRJZGVudGlmaWVyeB5wZXJzb25hbF9hZG1pbmlzdHJhdGl2ZV9udW1iZXLYGFiWpGZyYW5kb21YQORGPPefqUARR_Eph800rJNVltu3Qwl5UatEAJa-k3FU_deyVxAu3hrOOGoDuqjjuWmZmeYdhu2xFQV2UOGYOIJoZGlnZXN0SUQWbGVsZW1lbnRWYWx1ZW4wMDMwNjkxMjM0NTY3OHFlbGVtZW50SWRlbnRpZmllcnNtb2JpbGVfcGhvbmVfbnVtYmVy2BhYlqRmcmFuZG9tWEBA5XmzPcynaPkmXVuuFqNgvXvmCflhU4yyqRI7BvmfXntwLzepEmARVfKeY69JrcTKSqZtlR6T3N2NI9RRMzklaGRpZ2VzdElEGDRsZWxlbWVudFZhbHVlc3NhbXBsZUBzY3l0YWxlcy5jb21xZWxlbWVudElkZW50aWZpZXJtZW1haWxfYWRkcmVzc9gYWICkZnJhbmRvbVhAIFEFxy-51TkOPZA2ysDU_sqAWqckIdUybgj9RxZZPfOK8_weiVb-CgidqPm9vOFwkZ9R4mIv9bpCzornTFa9bGhkaWdlc3RJRAxsZWxlbWVudFZhbHVl9HFlbGVtZW50SWRlbnRpZmllcmthZ2Vfb3Zlcl8xNdgYWIGkZnJhbmRvbVhALLcQwCHFqNDMzrieGAvMw7_cQKjsQySyJ9iYbAL_A42ZYqOEdOGaaaePTCAGNNneyhf38CD5SYQ7y982snHNnmhkaWdlc3RJRBgpbGVsZW1lbnRWYWx1ZfRxZWxlbWVudElkZW50aWZpZXJrYWdlX292ZXJfMTjYGFiApGZyYW5kb21YQBsAzA4wjYVszmhVw58Nb7VshK3YNrCguc1qgiFczNQ0zznm1uMoWN5vab3inUAKEwcHgMcdJtRfcL1tWpiRagloZGlnZXN0SUQBbGVsZW1lbnRWYWx1ZfRxZWxlbWVudElkZW50aWZpZXJrYWdlX292ZXJfMjHYGFiBpGZyYW5kb21YQIOIpnrj8-cwTuFhm96Ydni_fODZPjhf-ylNGLcroqtOF9JJHmaAUPVPo1jpoK5F7pae4AX0T5-t-JS1irNWFP5oZGlnZXN0SUQYJWxlbGVtZW50VmFsdWX0cWVsZW1lbnRJZGVudGlmaWVya2FnZV9vdmVyXzYw2BhYgaRmcmFuZG9tWECTQLY5Alhy-ZVYBb3XndTAsCgNUGP_AoPAfJ3flYuNSeKCxERw6VAh2IuOWa9yvJetwxBpfWbb1HZf_RjeN_ZcaGRpZ2VzdElEGDxsZWxlbWVudFZhbHVl9HFlbGVtZW50SWRlbnRpZmllcmthZ2Vfb3Zlcl82NdgYWIGkZnJhbmRvbVhAYQyNG8P248TFk3cJHXwzGjAoGDIOj-ASt9swoL2083uvrm98XF1ePh9vV0doV9EIURVd3D3fW9m9NEQ46_prPmhkaWdlc3RJRBggbGVsZW1lbnRWYWx1ZfRxZWxlbWVudElkZW50aWZpZXJrYWdlX292ZXJfNjjYGFiCpGZyYW5kb21YQLm_4a49RUETl7Ird7rx9F1x7Ok_iwa6irlAMjeAaXSZ-p4zAc5CfkGtnPxWL9Q_xJh3GRrPVnd6mq5I2o4MRTpoZGlnZXN0SUQYPmxlbGVtZW50VmFsdWUAcWVsZW1lbnRJZGVudGlmaWVybGFnZV9pbl95ZWFyc9gYWIakZnJhbmRvbVhA-0Kyh3p8Oc3RwGXSmZdt1q094u777V_2CAvzFr4KdxPYME03k7S706uy7YnG1Wrot_tHvxQt05ZtzMQc0jltlmhkaWdlc3RJRBhGbGVsZW1lbnRWYWx1ZRkH6XFlbGVtZW50SWRlbnRpZmllcm5hZ2VfYmlydGhfeWVhcmppc3N1ZXJBdXRohEOhASahGCFZAkswggJHMIIB7aADAgECAgkz_hofAnNRlAkwCgYIKoZIzj0EAwIwOzELMAkGA1UEBhMCU0UxETAPBgNVBAoTCFNjeXRhbGVzMRkwFwYDVQQDExBTY3l0YWxlcyBSb290IENBMB4XDTI0MDkyOTExNDYwMFoXDTI1MDkyOTExNDYwMFowTzELMAkGA1UEBhMCU0UxETAPBgNVBAoTCFNjeXRhbGVzMS0wKwYDVQQDEyRTY3l0YWxlcyBEb2N1bWVudCBzaWduZXIgY2VydGlmaWNhdGUwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAASfskmRSFZjotdCDLZIpa8TClpJoqiPslZJzT34QJQzfNOedJtgbhCMdv8mAqPngREpJ23DkDWtsm8s8SDWztrpo4HFMIHCMB0GA1UdDgQWBBTVxA72zNx0xVbCVWOi0wK289OkAjAfBgNVHSMEGDAWgBQIDeRQcVE6OovURNywWfeEKxIesDAOBgNVHQ8BAf8EBAMCB4AwEgYDVR0lBAswCQYHKIGMXQUBAjAiBgNVHRIEGzAZhhdodHRwOi8vd3d3LnNjeXRhbGVzLmNvbTA4BgNVHR8EMTAvMC2gK6AphidodHRwczovL3N0YXRpYy5tZG9jLmlkL2NybC9zY3l0YWxlcy5jcmwwCgYIKoZIzj0EAwIDSAAwRQIgI35qoMg1PWunRqDz_8aybyoFAdbmBUkSC1sk1LJePzgCIQCeCs2QOOREsoN2RjRxFXgriVKlUOs6J6INxUEVJpTkX1kG3tgYWQbZp2ZzdGF0dXOha3N0YXR1c19saXN0omNpZHgYxWN1cml4Vmh0dHBzOi8vYXBpLm5leHQuZ2xvYmFsLm1kb2MuaWQvd2FsbGV0L1N0YXR1c1BhZ2VMaXN0L2UwNjI2ZjM0NWRiMjRiMjY5NWRiZjE1NTA2ZWE5YWIzZ2RvY1R5cGV3ZXUuZXVyb3BhLmVjLmV1ZGkucGlkLjFndmVyc2lvbmMxLjBsdmFsaWRpdHlJbmZvpGZzaWduZWTAdDIwMjUtMDktMjNUMDg6MTA6MzJaaXZhbGlkRnJvbcB0MjAyNS0wOS0yM1QwODoxMDozMlpqdmFsaWRVbnRpbMB0MjAyNS0wOS0yOVQxMTo0NjowMFpuZXhwZWN0ZWRVcGRhdGXAdDIwMjUtMDktMjlUMTE6NDY6MDBabHZhbHVlRGlnZXN0c6F3ZXUuZXVyb3BhLmVjLmV1ZGkucGlkLjG4JABYINzcyU1eDpFiIErvHhRYeNeX0TAs_a6l1BtysmoTg09_AVggIffN__Dp6N6X_8WTueD6YPGF3FH2gQdws8Vqsw_7r7oCWCB4iv18IAzhd3R0hjDchbax7Z-T1jNWUXU8GA0Z1q_lZANYIHogrLcxsJGxUR8I36GKsVe90WPBSy7xOavNEmbwwKCXBFggzWWKKmHT8gxXRSdQ9A-wzu48tZnmSwxsAR3zG_YfV_sFWCCK4ifvChkBA9YZTwKQcBb72SFoE99uwSz9v0PAnntZ6AZYIFW7R07G1UGWl9sDQv7Lcp1xy7KSOUtyPGa9DeR5KG6BCFggGnLM_HDDEVK5YY0tnIa5K2RFm1i_cnpcxPkutdjeEpULWCAdArGBNbvmxaW1rqvJlScDpyMXmGR-9geFb-ZVlooHmwxYICLz8tlhRGVoDIBNsOPk9F-Z-l_c7AMVMdq64Qh2Y2H3DlggJEisaCwF99ISDZ82Y502nP2pW5dgHxWJfnPrsMHPgmMRWCAK-fsnvR2TI8Pq6Z8J95nla67YqgMCC3D-JmWJEBvoMhJYIHv0-yPZdjq0WjyglmfUNnanMtWqkmB60L-fTEDep_wHFVggzb1djU9jPoEC8ElofEFKDHKDiJIFq60h5iJPi_mqKtIWWCD2KLZBWykNouHBq-1t0grIoPB_RJ9-UzGBq0XjDod7GxdYIPxlgE-fpByBpBBK381Hto9DUwPMEGERSJFc7MWmH5RhGBpYIByxQ5FRECoqF_DfM3BXlJJcGYunqq0IKoi2hf4CI5szGBtYIFEXGHEKywXhxAUm6l9y6ASAGRAQAdtkv2QWOJBiherfGB5YIOb8LSrY1ez9VyCkYEuk0t6TB9FWCN3Cpdg6Hki32i2qGCBYIGj2m0qtySO0KdcYgMHW5r_hLZbxGQymrO7I37ZIXaVuGCJYILUYFkt10lJRtt7sWRHT4wFgC5dBVaW1J6uEeURkyVGbGCVYIKmgabbb4CZvACVhn2W7EdwGVKm8kHdkCobEBx5IkQWLGCZYIJlfVCcJJ9hNRmBJ5MqpQ0fD5oBGK-QzZuyrCj9yNtcjGCdYIDTtQLiqCqVOk7RObFOyaUtU7ViekVEX83kihKomPOuuGClYION_C6SZMnYJag-l22Ly9bQO-nvnvpdcDpwzDKAP7XYhGCpYICup5Jme7UNJfENjCv_gAe9aOZ5XxNz5uBCKVJ78KGOcGC9YIPftSboQfxricO71s3GCBdqiQarWoczb94LgLPKTQs0iGDBYIC6k5E6DSIKndaG7r-8kDzuX1mKgZV1peARkpnWLRCnCGDRYIGe24gvGaHkYJgHUYwqTFqug__VXJNADyPMaglTAlgq9GDVYIE5z5LBraauZrRhrh6ErQMFPFoMoHEpkWg6iMFHFq72GGDxYIAfyCmGMDkWps8RyCVs5Knesx00jaoRL3aegkXQl7QAkGD5YIK27HbsN3lSE3H-Fkzxvw1dCNf18Nxn4cYhk_B-sEGVYGEBYIABY1kHlKaHuF2UtGcI5bhXk5yvpuZOIRgeA7sBYOgoSGEJYIF6IXZYbvUF0g_giP0IXDAVMxByYwniw1U_w7VWHW2gbGENYIMxQ-pc1ICGdc-U59xyTlY8DYVzqK-pKju49EPKWv5PvGEZYIGnnPs_iI-Mgneo9OmUa3R50T6VVZ5dgZ8gv-5Vy0gOUbWRldmljZUtleUluZm-haWRldmljZUtleaQBAiABIVgg3w4XeUWGBvzMA4tTs9CmNbIgGyHKe414kTHogLooP30iWCAfspAHA_SdPlHX5w4GNrNlMsPaRT0LIG900cHukizWcW9kaWdlc3RBbGdvcml0aG1nU0hBLTI1NlhAUOtMSb1Xb_DL3sffs8hfgWLX_wzjpRneSTca2zIJZaD62umnv7f8dt_xRDDwsNZRvX-86r3diWV9rc8vhepSqWxkZXZpY2VTaWduZWSiam5hbWVTcGFjZXPYGEGgamRldmljZUF1dGihb2RldmljZVNpZ25hdHVyZYRDoQEmoPZYQJIpDvrJMzsf3RhJJLFtzZo1bxaTeDy3F8yhf2nWsrNyp02ZAAMhmudsVroi9lUJhjvYlg6tPzizyNOIsBaG4nxmc3RhdHVzAA"
  
  static let x5cCertificate = "MIIDSTCCAjGgAwIBAgIUBAfbyjpjLFsSTAaCY43xSz/aKB8wDQYJKoZIhvcNAQELBQAwFjEUMBIGA1UEAwwLZXhhbXBsZS5jb20wHhcNMjQwMTEwMTQzNTQyWhcNMjUwMTA5MTQzNTQyWjAWMRQwEgYDVQQDDAtleGFtcGxlLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK6JArDMWQH+JImQW4Kdlzt25obTlUzmXQBMHVZ47M5VgPBAQ25Db8y7ev7CVV7WFTxNrISLER0tVW47I7H4mzfbcK1UCEyRA6A1uwbfdw1af4ajOuVqoWqJFB2zqK3VmjymqWAvSPfnXR1UyMQQj2NObABz4YacuuK3uzcOKnmHYQ8adavzvPLmeA06s9Hjk6RjEoCazAngYABdA3bVfi6TS0Nqj4B5580BVu5HFTj8Pw7aDBVQ6tj/uBgJW4tKQlARn3aMGJbZ1zUC2pFyJ8bMQnejqmuD4mJpmPf+Ihz4nQlYTFKFlK3ASRZjfgDd3rkktPu8CQ9Sg1bTaZWOw1UCAwEAAaOBjjCBizBqBgNVHREEYzBhggtleGFtcGxlLmNvbYIVc3ViZG9tYWluLmV4YW1wbGUuY29tghxjbGllbnRfaWRlbnRpZmVyLmV4YW1wbGUuY29thwTAqAEBhhdodHRwczovL3d3dy5leGFtcGxlLmNvbTAdBgNVHQ4EFgQUEkq36yycm2K2uF1lYCOZDwHmFmIwDQYJKoZIhvcNAQELBQADggEBAIz/fqjYX6iFYqJyJVESoXuLigceG/mGz2mOnXnA5EDjZqk+0rwngMA4So8cHSUcD31UNmG26zWrPM1gFVkjZNn5gcpxdRkYzONDbBNFKoHBxUJIRvDuR3JpesI7aBmYWr3gm68EYa2CUyUztW7hIc7KAao85UI5Q49o9cJxT6EjwDXz8NsJS6lHCDEP7R0ZBjI1Qnv8BIzZKsLoPMt5LxUCVpoV+MjrcKIBTsoISJpI4SAYG/Yz1YWlhSD1rYNax1V21EeN9T+E111JqVve2AQMr3CLLtMAiY5jPIXlFvtiIUtY9I3uGdd2QA/HNiE87Q6o07wf8n/groYy2fVONYo="
  
  static let x5cRootCertificate = "MIIDdzCCAl+gAwIBAgIEAgAAuTANBgkqhkiG9w0BAQUFADBaMQswCQYDVQQGEwJJRTESMBAGA1UEChMJQmFsdGltb3JlMRMwEQYDVQQLEwpDeWJlclRydXN0MSIwIAYDVQQDExlCYWx0aW1vcmUgQ3liZXJUcnVzdCBSb290MB4XDTAwMDUxMjE4NDYwMFoXDTI1MDUxMjIzNTkwMFowWjELMAkGA1UEBhMCSUUxEjAQBgNVBAoTCUJhbHRpbW9yZTETMBEGA1UECxMKQ3liZXJUcnVzdDEiMCAGA1UEAxMZQmFsdGltb3JlIEN5YmVyVHJ1c3QgUm9vdDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKMEuyKrmD1X6CZymrV51Cni4eiVgLGw41uOKymaZN+hXe2wCQVt2yguzmKiYv60iNoS6zjrIZ3AQSsBUnuId9Mcj8e6uYi1agnnc+gRQKfRzMpijS3ljwumUNKoUMMo6vWrJYeKmpYcqWe4PwzV9/lSEy/CG9VwcPCPwBLKBsua4dnKM3p31vjsufFoREJIE9LAwqSuXmD+tqYF/LTdB1kC1FkYmGP1pWPgkAx9XbIGevOF6uvUA65ehD5f/xXtabz5OTZydc93Uk3zyZAsuT3lySNTPx8kmCFcB5kpvcY67Oduhjprl3RjM71oGDHweI12v/yejl0qhqdNkNwnGjkCAwEAAaNFMEMwHQYDVR0OBBYEFOWdWTCCR1jMrPoIVDaGezq1BE3wMBIGA1UdEwEB/wQIMAYBAf8CAQMwDgYDVR0PAQH/BAQDAgEGMA0GCSqGSIb3DQEBBQUAA4IBAQCFDF2O5G9RaEIFoN27TyclhAO992T9Ldcw46QQF+vaKSm2eT929hkTI7gQCvlYpNRhcL0EYWoSihfVCr3FvDB81ukMJY2GQE/szKN+OMY3EU/t3WgxjkzSswF07r51XgdIGn9w/xZchMB5hbgF/X++ZRGjD8ACtPhSNzkE1akxehi/oCr0Epn3o0WC4zxe9Z2etciefC7IpJ5OCBRLbf1wbWsaY71k5h+3zvDyny67G7fyUIhzksLi4xaNmjICq44Y3ekQEe5+NauQrz4wlHrQMz2nZQ/1/I6eYs9HRCwBXbsdtTLSR9I4LtD+gdwyah617jzV/OeBHRnDJELqYzmp"
  
  static let x5cRootCertificateBase64 = "TUlJRGR6Q0NBbCtnQXdJQkFnSUVBZ0FBdVRBTkJna3Foa2lHOXcwQkFRVUZBREJhTVFzd0NRWURWUVFHRXdKSlJURVNNQkFHQTFVRUNoTUpRbUZzZEdsdGIzSmxNUk13RVFZRFZRUUxFd3BEZVdKbGNsUnlkWE4wTVNJd0lBWURWUVFERXhsQ1lXeDBhVzF2Y21VZ1EzbGlaWEpVY25WemRDQlNiMjkwTUI0WERUQXdNRFV4TWpFNE5EWXdNRm9YRFRJMU1EVXhNakl6TlRrd01Gb3dXakVMTUFrR0ExVUVCaE1DU1VVeEVqQVFCZ05WQkFvVENVSmhiSFJwYlc5eVpURVRNQkVHQTFVRUN4TUtRM2xpWlhKVWNuVnpkREVpTUNBR0ExVUVBeE1aUW1Gc2RHbHRiM0psSUVONVltVnlWSEoxYzNRZ1VtOXZkRENDQVNJd0RRWUpLb1pJaHZjTkFRRUJCUUFEZ2dFUEFEQ0NBUW9DZ2dFQkFLTUV1eUtybUQxWDZDWnltclY1MUNuaTRlaVZnTEd3NDF1T0t5bWFaTitoWGUyd0NRVnQyeWd1em1LaVl2NjBpTm9TNnpqcklaM0FRU3NCVW51SWQ5TWNqOGU2dVlpMWFnbm5jK2dSUUtmUnpNcGlqUzNsand1bVVOS29VTU1vNnZXckpZZUttcFljcVdlNFB3elY5L2xTRXkvQ0c5VndjUENQd0JMS0JzdWE0ZG5LTTNwMzF2anN1ZkZvUkVKSUU5TEF3cVN1WG1EK3RxWUYvTFRkQjFrQzFGa1ltR1AxcFdQZ2tBeDlYYklHZXZPRjZ1dlVBNjVlaEQ1Zi94WHRhYno1T1RaeWRjOTNVazN6eVpBc3VUM2x5U05UUHg4a21DRmNCNWtwdmNZNjdPZHVoanBybDNSak03MW9HREh3ZUkxMnYveWVqbDBxaHFkTmtOd25HamtDQXdFQUFhTkZNRU13SFFZRFZSME9CQllFRk9XZFdUQ0NSMWpNclBvSVZEYUdlenExQkUzd01CSUdBMVVkRXdFQi93UUlNQVlCQWY4Q0FRTXdEZ1lEVlIwUEFRSC9CQVFEQWdFR01BMEdDU3FHU0liM0RRRUJCUVVBQTRJQkFRQ0ZERjJPNUc5UmFFSUZvTjI3VHljbGhBTzk5MlQ5TGRjdzQ2UVFGK3ZhS1NtMmVUOTI5aGtUSTdnUUN2bFlwTlJoY0wwRVlXb1NpaGZWQ3IzRnZEQjgxdWtNSlkyR1FFL3N6S04rT01ZM0VVL3QzV2d4amt6U3N3RjA3cjUxWGdkSUduOXcveFpjaE1CNWhiZ0YvWCsrWlJHakQ4QUN0UGhTTnprRTFha3hlaGkvb0NyMEVwbjNvMFdDNHp4ZTlaMmV0Y2llZkM3SXBKNU9DQlJMYmYxd2JXc2FZNzFrNWgrM3p2RHlueTY3RzdmeVVJaHprc0xpNHhhTm1qSUNxNDRZM2VrUUVlNStOYXVRcno0d2xIclFNejJuWlEvMS9JNmVZczlIUkN3Qlhic2R0VExTUjlJNEx0RCtnZHd5YWg2MTdqelYvT2VCSFJuREpFTHFZem1w"
  
  static let x5cLeafCertificate = "MIIFDTCCBLSgAwIBAgIQDfGp1LldLaZknAqfNm6mjjAKBggqhkjOPQQDAjBKMQswCQYDVQQGEwJVUzEZMBcGA1UEChMQQ2xvdWRmbGFyZSwgSW5jLjEgMB4GA1UEAxMXQ2xvdWRmbGFyZSBJbmMgRUNDIENBLTMwHhcNMjMxMDI1MDAwMDAwWhcNMjQxMDIzMjM1OTU5WjBvMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMNU2FuIEZyYW5jaXNjbzEZMBcGA1UEChMQQ2xvdWRmbGFyZSwgSW5jLjEYMBYGA1UEAxMPY2hhdC5vcGVuYWkuY29tMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAELYia1YcrVMZDdt21jKAVP00D1hWwJbX3Pd2SERdzLyUqr8CW8p/n9YO2Bdgsszekb1XX7CgWfmZfs08DfDcPMaOCA1UwggNRMB8GA1UdIwQYMBaAFKXON+rrsHUOlGeItEX62SQQh5YfMB0GA1UdDgQWBBSR6aH1PDM4iTtuGDa0ci+taEWHeTAaBgNVHREEEzARgg9jaGF0Lm9wZW5haS5jb20wPgYDVR0gBDcwNTAzBgZngQwBAgIwKTAnBggrBgEFBQcCARYbaHR0cDovL3d3dy5kaWdpY2VydC5jb20vQ1BTMA4GA1UdDwEB/wQEAwIDiDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwewYDVR0fBHQwcjA3oDWgM4YxaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0Nsb3VkZmxhcmVJbmNFQ0NDQS0zLmNybDA3oDWgM4YxaHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0Nsb3VkZmxhcmVJbmNFQ0NDQS0zLmNybDB2BggrBgEFBQcBAQRqMGgwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBABggrBgEFBQcwAoY0aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0Nsb3VkZmxhcmVJbmNFQ0NDQS0zLmNydDAMBgNVHRMBAf8EAjAAMIIBfwYKKwYBBAHWeQIEAgSCAW8EggFrAWkAdgDuzdBk1dsazsVct520zROiModGfLzs3sNRSFlGcR+1mwAAAYtpJO4UAAAEAwBHMEUCIQCeR80NFsZ961ocA8DIFtGkwX+MnQ6Ryp8x9tUs7jcbPgIgE5JNCvaagJwIMC8AFYoPMczWedJubjclrItI5SpJ0gEAdgBIsONr2qZHNA/lagL6nTDrHFIBy1bdLIHZu7+rOdiEcwAAAYtpJO4YAAAEAwBHMEUCIEaLHTthPluTtu7wHFcn3rP1IaNY4oyAK+fEaX4M+LzTAiEAgfnXCLZXb1EFj0X76v1FRdWAFMRUfFtkxOpJvCxO7CEAdwDatr9rP7W2Ip+bwrtca+hwkXFsu1GEhTS9pD0wSNf7qwAAAYtpJO5GAAAEAwBIMEYCIQCz3Iiv0ocincv60Ewqc72M+WRtT7s8UVOWinZdymJ/vgIhAIffJ2B2RL2JSOIwM2RFtvMWH4tWtvoITeM90GhyrcM8MAoGCCqGSM49BAMCA0cAMEQCIAnLrRHKoNYvyqd77IFmBKKhUlKHieUsPayLDB4sn50KAiB44aQ9lfDJIXiabR2bKrIK2uRh9tsuQz146L4BAFT7Gw=="
  
  static let x5cLeafCertificateBase64 = "TUlJRkRUQ0NCTFNnQXdJQkFnSVFEZkdwMUxsZExhWmtuQXFmTm02bWpqQUtCZ2dxaGtqT1BRUURBakJLTVFzd0NRWURWUVFHRXdKVlV6RVpNQmNHQTFVRUNoTVFRMnh2ZFdSbWJHRnlaU3dnU1c1akxqRWdNQjRHQTFVRUF4TVhRMnh2ZFdSbWJHRnlaU0JKYm1NZ1JVTkRJRU5CTFRNd0hoY05Nak14TURJMU1EQXdNREF3V2hjTk1qUXhNREl6TWpNMU9UVTVXakJ2TVFzd0NRWURWUVFHRXdKVlV6RVRNQkVHQTFVRUNCTUtRMkZzYVdadmNtNXBZVEVXTUJRR0ExVUVCeE1OVTJGdUlFWnlZVzVqYVhOamJ6RVpNQmNHQTFVRUNoTVFRMnh2ZFdSbWJHRnlaU3dnU1c1akxqRVlNQllHQTFVRUF4TVBZMmhoZEM1dmNHVnVZV2t1WTI5dE1Ga3dFd1lIS29aSXpqMENBUVlJS29aSXpqMERBUWNEUWdBRUxZaWExWWNyVk1aRGR0MjFqS0FWUDAwRDFoV3dKYlgzUGQyU0VSZHpMeVVxcjhDVzhwL245WU8yQmRnc3N6ZWtiMVhYN0NnV2ZtWmZzMDhEZkRjUE1hT0NBMVV3Z2dOUk1COEdBMVVkSXdRWU1CYUFGS1hPTitycnNIVU9sR2VJdEVYNjJTUVFoNVlmTUIwR0ExVWREZ1FXQkJTUjZhSDFQRE00aVR0dUdEYTBjaSt0YUVXSGVUQWFCZ05WSFJFRUV6QVJnZzlqYUdGMExtOXdaVzVoYVM1amIyMHdQZ1lEVlIwZ0JEY3dOVEF6QmdabmdRd0JBZ0l3S1RBbkJnZ3JCZ0VGQlFjQ0FSWWJhSFIwY0RvdkwzZDNkeTVrYVdkcFkyVnlkQzVqYjIwdlExQlRNQTRHQTFVZER3RUIvd1FFQXdJRGlEQWRCZ05WSFNVRUZqQVVCZ2dyQmdFRkJRY0RBUVlJS3dZQkJRVUhBd0l3ZXdZRFZSMGZCSFF3Y2pBM29EV2dNNFl4YUhSMGNEb3ZMMk55YkRNdVpHbG5hV05sY25RdVkyOXRMME5zYjNWa1pteGhjbVZKYm1ORlEwTkRRUzB6TG1OeWJEQTNvRFdnTTRZeGFIUjBjRG92TDJOeWJEUXVaR2xuYVdObGNuUXVZMjl0TDBOc2IzVmtabXhoY21WSmJtTkZRME5EUVMwekxtTnliREIyQmdnckJnRUZCUWNCQVFScU1HZ3dKQVlJS3dZQkJRVUhNQUdHR0doMGRIQTZMeTl2WTNOd0xtUnBaMmxqWlhKMExtTnZiVEJBQmdnckJnRUZCUWN3QW9ZMGFIUjBjRG92TDJOaFkyVnlkSE11WkdsbmFXTmxjblF1WTI5dEwwTnNiM1ZrWm14aGNtVkpibU5GUTBORFFTMHpMbU55ZERBTUJnTlZIUk1CQWY4RUFqQUFNSUlCZndZS0t3WUJCQUhXZVFJRUFnU0NBVzhFZ2dGckFXa0FkZ0R1emRCazFkc2F6c1ZjdDUyMHpST2lNb2RHZkx6czNzTlJTRmxHY1IrMW13QUFBWXRwSk80VUFBQUVBd0JITUVVQ0lRQ2VSODBORnNaOTYxb2NBOERJRnRHa3dYK01uUTZSeXA4eDl0VXM3amNiUGdJZ0U1Sk5DdmFhZ0p3SU1DOEFGWW9QTWN6V2VkSnViamNsckl0STVTcEowZ0VBZGdCSXNPTnIycVpITkEvbGFnTDZuVERySEZJQnkxYmRMSUhadTcrck9kaUVjd0FBQVl0cEpPNFlBQUFFQXdCSE1FVUNJRWFMSFR0aFBsdVR0dTd3SEZjbjNyUDFJYU5ZNG95QUsrZkVhWDRNK0x6VEFpRUFnZm5YQ0xaWGIxRUZqMFg3NnYxRlJkV0FGTVJVZkZ0a3hPcEp2Q3hPN0NFQWR3RGF0cjlyUDdXMklwK2J3cnRjYStod2tYRnN1MUdFaFRTOXBEMHdTTmY3cXdBQUFZdHBKTzVHQUFBRUF3QklNRVlDSVFDejNJaXYwb2NpbmN2NjBFd3FjNzJNK1dSdFQ3czhVVk9XaW5aZHltSi92Z0loQUlmZkoyQjJSTDJKU09Jd00yUkZ0dk1XSDR0V3R2b0lUZU05MEdoeXJjTThNQW9HQ0NxR1NNNDlCQU1DQTBjQU1FUUNJQW5MclJIS29OWXZ5cWQ3N0lGbUJLS2hVbEtIaWVVc1BheUxEQjRzbjUwS0FpQjQ0YVE5bGZESklYaWFiUjJiS3JJSzJ1Umg5dHN1UXoxNDZMNEJBRlQ3R3c9PQ=="
  
  static let x5cInterCertificate = "MIIDzTCCArWgAwIBAgIQCjeHZF5ftIwiTv0b7RQMPDANBgkqhkiG9w0BAQsFADBaMQswCQYDVQQGEwJJRTESMBAGA1UEChMJQmFsdGltb3JlMRMwEQYDVQQLEwpDeWJlclRydXN0MSIwIAYDVQQDExlCYWx0aW1vcmUgQ3liZXJUcnVzdCBSb290MB4XDTIwMDEyNzEyNDgwOFoXDTI0MTIzMTIzNTk1OVowSjELMAkGA1UEBhMCVVMxGTAXBgNVBAoTEENsb3VkZmxhcmUsIEluYy4xIDAeBgNVBAMTF0Nsb3VkZmxhcmUgSW5jIEVDQyBDQS0zMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEua1NZpkUC0bsH4HRKlAenQMVLzQSfS2WuIg4m4Vfj7+7Te9hRsTJc9QkT+DuHM5ss1FxL2ruTAUJd9NyYqSb16OCAWgwggFkMB0GA1UdDgQWBBSlzjfq67B1DpRniLRF+tkkEIeWHzAfBgNVHSMEGDAWgBTlnVkwgkdYzKz6CFQ2hns6tQRN8DAOBgNVHQ8BAf8EBAMCAYYwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMBIGA1UdEwEB/wQIMAYBAf8CAQAwNAYIKwYBBQUHAQEEKDAmMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wOgYDVR0fBDMwMTAvoC2gK4YpaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL09tbmlyb290MjAyNS5jcmwwbQYDVR0gBGYwZDA3BglghkgBhv1sAQEwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzALBglghkgBhv1sAQIwCAYGZ4EMAQIBMAgGBmeBDAECAjAIBgZngQwBAgMwDQYJKoZIhvcNAQELBQADggEBAAUkHd0bsCrrmNaF4zlNXmtXnYJX/OvoMaJXkGUFvhZEOFp3ArnPEELG4ZKk40Un+ABHLGioVplTVI+tnkDB0A+21w0LOEhsUCxJkAZbZB2LzEgwLt4I4ptJIsCSDBFelpKU1fwg3FZs5ZKTv3ocwDfjhUkV+ivhdDkYD7fa86JXWGBPzI6UAPxGezQxPk1HgoE6y/SJXQ7vTQ1unBuCJN0yJV0ReFEQPaA1IwQvZW+cwdFD19Ae8zFnWSfda9J1CZMRJCQUzym+5iPDuI9yP+kHyCREU3qzuWFloUwOxkgAyXVjBYdwRVKD05WdRerw6DEdfgkfCv4+3ao8XnTSrLE="
  
  static let x5cInterCertificateBase64 = "TUlJRHpUQ0NBcldnQXdJQkFnSVFDamVIWkY1ZnRJd2lUdjBiN1JRTVBEQU5CZ2txaGtpRzl3MEJBUXNGQURCYU1Rc3dDUVlEVlFRR0V3SkpSVEVTTUJBR0ExVUVDaE1KUW1Gc2RHbHRiM0psTVJNd0VRWURWUVFMRXdwRGVXSmxjbFJ5ZFhOME1TSXdJQVlEVlFRREV4bENZV3gwYVcxdmNtVWdRM2xpWlhKVWNuVnpkQ0JTYjI5ME1CNFhEVEl3TURFeU56RXlORGd3T0ZvWERUSTBNVEl6TVRJek5UazFPVm93U2pFTE1Ba0dBMVVFQmhNQ1ZWTXhHVEFYQmdOVkJBb1RFRU5zYjNWa1pteGhjbVVzSUVsdVl5NHhJREFlQmdOVkJBTVRGME5zYjNWa1pteGhjbVVnU1c1aklFVkRReUJEUVMwek1Ga3dFd1lIS29aSXpqMENBUVlJS29aSXpqMERBUWNEUWdBRXVhMU5acGtVQzBic0g0SFJLbEFlblFNVkx6UVNmUzJXdUlnNG00VmZqNys3VGU5aFJzVEpjOVFrVCtEdUhNNXNzMUZ4TDJydVRBVUpkOU55WXFTYjE2T0NBV2d3Z2dGa01CMEdBMVVkRGdRV0JCU2x6amZxNjdCMURwUm5pTFJGK3Rra0VJZVdIekFmQmdOVkhTTUVHREFXZ0JUbG5Wa3dna2RZekt6NkNGUTJobnM2dFFSTjhEQU9CZ05WSFE4QkFmOEVCQU1DQVlZd0hRWURWUjBsQkJZd0ZBWUlLd1lCQlFVSEF3RUdDQ3NHQVFVRkJ3TUNNQklHQTFVZEV3RUIvd1FJTUFZQkFmOENBUUF3TkFZSUt3WUJCUVVIQVFFRUtEQW1NQ1FHQ0NzR0FRVUZCekFCaGhob2RIUndPaTh2YjJOemNDNWthV2RwWTJWeWRDNWpiMjB3T2dZRFZSMGZCRE13TVRBdm9DMmdLNFlwYUhSMGNEb3ZMMk55YkRNdVpHbG5hV05sY25RdVkyOXRMMDl0Ym1seWIyOTBNakF5TlM1amNtd3diUVlEVlIwZ0JHWXdaREEzQmdsZ2hrZ0JodjFzQVFFd0tqQW9CZ2dyQmdFRkJRY0NBUlljYUhSMGNITTZMeTkzZDNjdVpHbG5hV05sY25RdVkyOXRMME5RVXpBTEJnbGdoa2dCaHYxc0FRSXdDQVlHWjRFTUFRSUJNQWdHQm1lQkRBRUNBakFJQmdabmdRd0JBZ013RFFZSktvWklodmNOQVFFTEJRQURnZ0VCQUFVa0hkMGJzQ3JybU5hRjR6bE5YbXRYbllKWC9Pdm9NYUpYa0dVRnZoWkVPRnAzQXJuUEVFTEc0WktrNDBVbitBQkhMR2lvVnBsVFZJK3Rua0RCMEErMjF3MExPRWhzVUN4SmtBWmJaQjJMekVnd0x0NEk0cHRKSXNDU0RCRmVscEtVMWZ3ZzNGWnM1WktUdjNvY3dEZmpoVWtWK2l2aGREa1lEN2ZhODZKWFdHQlB6STZVQVB4R2V6UXhQazFIZ29FNnkvU0pYUTd2VFExdW5CdUNKTjB5SlYwUmVGRVFQYUExSXdRdlpXK2N3ZEZEMTlBZTh6Rm5XU2ZkYTlKMUNaTVJKQ1FVenltKzVpUER1STl5UCtrSHlDUkVVM3F6dVdGbG9Vd094a2dBeVhWakJZZHdSVktEMDVXZFJlcnc2REVkZmdrZkN2NCszYW84WG5UU3JMRT0="
  
  static let verifierCertificate = "MIIDDDCCArKgAwIBAgIUG8SguUrbgpJUvd6v+07Sp8utLfQwCgYIKoZIzj0EAwIwXDEeMBwGA1UEAwwVUElEIElzc3VlciBDQSAtIFVUIDAyMS0wKwYDVQQKDCRFVURJIFdhbGxldCBSZWZlcmVuY2UgSW1wbGVtZW50YXRpb24xCzAJBgNVBAYTAlVUMB4XDTI1MDQxMDA2NDU1OFoXDTI3MDQxMDA2NDU1N1owVzEdMBsGA1UEAwwURVVESSBSZW1vdGUgVmVyaWZpZXIxCjAIBgNVBAUTATExHTAbBgNVBAoMFEVVREkgUmVtb3RlIFZlcmlmaWVyMQswCQYDVQQGEwJVVDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABOciV42mIT8nQMAN8kW9CHNUTYwkieem5hl1QsLf62kEbbZh6wul5iL28g/A3ZqcTX9XoLnw/nvJ8/HRp3+95eKjggFVMIIBUTAMBgNVHRMBAf8EAjAAMB8GA1UdIwQYMBaAFGLHlEcovQ+iFiCnmsJJlETxAdPHMDkGA1UdEQQyMDCBEm5vLXJlcGx5QGV1ZGl3LmRldoIadmVyaWZpZXItYmFja2VuZC5ldWRpdy5kZXYwEgYDVR0lBAswCQYHKIGMXQUBBjBDBgNVHR8EPDA6MDigNqA0hjJodHRwczovL3ByZXByb2QucGtpLmV1ZGl3LmRldi9jcmwvcGlkX0NBX1VUXzAyLmNybDAdBgNVHQ4EFgQUgAh9KsoYXYK8jndUbFQEtfDsHjYwDgYDVR0PAQH/BAQDAgeAMF0GA1UdEgRWMFSGUmh0dHBzOi8vZ2l0aHViLmNvbS9ldS1kaWdpdGFsLWlkZW50aXR5LXdhbGxldC9hcmNoaXRlY3R1cmUtYW5kLXJlZmVyZW5jZS1mcmFtZXdvcmswCgYIKoZIzj0EAwIDSAAwRQIgDFCgyEjGnJS25n/FfdP7HX0elz7C2q4uUQ/7Zcrl0QYCIQC/rrJpQ5sF1O4aiHejIPPLuO3JjdrLJPZSA+FQH+eIrA=="
  
  static let sdJwtVcPid = "eyJ4NWMiOlsiTUlJQzZ6Q0NBcEdnQXdJQkFnSVViWDhuYllTTFJ2eTEwbUtOK2hmQ1ZyLzhjQmN3Q2dZSUtvWkl6ajBFQXdJd1hERWVNQndHQTFVRUF3d1ZVRWxFSUVsemMzVmxjaUJEUVNBdElGVlVJREF5TVMwd0t3WURWUVFLRENSRlZVUkpJRmRoYkd4bGRDQlNaV1psY21WdVkyVWdTVzF3YkdWdFpXNTBZWFJwYjI0eEN6QUpCZ05WQkFZVEFsVlVNQjRYRFRJMU1EUXhNREUwTWpVME1Gb1hEVEkyTURjd05ERTBNalV6T1Zvd1VqRVVNQklHQTFVRUF3d0xVRWxFSUVSVElDMGdNRE14TFRBckJnTlZCQW9NSkVWVlJFa2dWMkZzYkdWMElGSmxabVZ5Wlc1alpTQkpiWEJzWlcxbGJuUmhkR2x2YmpFTE1Ba0dBMVVFQmhNQ1ZWUXdXVEFUQmdjcWhrak9QUUlCQmdncWhrak9QUU1CQndOQ0FBU3J4WjEzd0xqL25VdUdlYllSbVBPMHE3cFJrMXgxU2pycUxUdnRRRnBRY3k5VHdGQ2NnaWUvQkJDMmovS3BMY0NyK29qNHR5WkFvZm12SGRhVEV4YkJvNElCT1RDQ0FUVXdId1lEVlIwakJCZ3dGb0FVWXNlVVJ5aTlENklXSUtlYXdrbVVSUEVCMDhjd0p3WURWUjBSQkNBd0hvSWNaR1YyTG1semMzVmxjaTFpWVdOclpXNWtMbVYxWkdsM0xtUmxkakFXQmdOVkhTVUJBZjhFRERBS0JnZ3JnUUlDQUFBQkFqQkRCZ05WSFI4RVBEQTZNRGlnTnFBMGhqSm9kSFJ3Y3pvdkwzQnlaWEJ5YjJRdWNHdHBMbVYxWkdsM0xtUmxkaTlqY213dmNHbGtYME5CWDFWVVh6QXlMbU55YkRBZEJnTlZIUTRFRmdRVWNzM0t5cWl6SGd0WFJlMzJuNkpCSkhBZmFMWXdEZ1lEVlIwUEFRSC9CQVFEQWdlQU1GMEdBMVVkRWdSV01GU0dVbWgwZEhCek9pOHZaMmwwYUhWaUxtTnZiUzlsZFMxa2FXZHBkR0ZzTFdsa1pXNTBhWFI1TFhkaGJHeGxkQzloY21Ob2FYUmxZM1IxY21VdFlXNWtMWEpsWm1WeVpXNWpaUzFtY21GdFpYZHZjbXN3Q2dZSUtvWkl6ajBFQXdJRFNBQXdSUUlnVFZabmNoRCtRanE1M1hzMG9jMDd5M3pHNmtBWEZrSitaS3psVkcyMnNDOENJUUR0RE1RcTBRbS9mUTVvcnJqUlQ0WEIrMEpiNnhGUHhYOVFrVlJhTXkvSWlBPT0iXSwia2lkIjoiNjI1MTE1NjIzMzA2MTIyNDk0ODA5Njg1MDI2ODI2NDM5OTAyMzM0MDY5NTM0NzQzIiwidHlwIjoiZGMrc2Qtand0IiwiYWxnIjoiRVMyNTYifQ.eyJfc2QiOlsiNExsckVReF9zSFRueC1wYUhTdlBUTWVZTXBHb1U0VFVkX0dmaXdaY3E3NCIsIjY5NlY4WTJJMWJPRjRrZTJUdnBIRm5sY3E0aG9XVEgzeXJQSWNScl9GUkkiLCI4Z21NMi1rY3dFVlJsSXUwRm1XcUhpSmdLVDB5eENIQ1pkYkNWNTNJLXEwIiwiQjM5SmtYc19LNllxRC1IUTJCeTUta2ZRdlZ6OGNsdkFkcE5fTzFJU2hubyIsIkV0UUo2UVhlRTJvbWYzYTlzbWtCNEJlMHVZNGdwME4wVjlRY3lFQ1p1OXciLCJGMkNLVUpSWVUyZUUxTXNpVWFJbi1DU2xtUjA4TDFkYks5R3ZIWUVqQnVrIiwiSVFIc0N6UlRsTThJXzlyTHo4TUdIM1J0TmR0bTdwMWlhS2ZYSlJjbFBrUSIsIklUVHlPZjNrNEhFZUdhNHd5bl9Ed3VYN0JRWFkzTzl3amczMTFWMEZpWWMiLCJPZzR6eFlQYjJpSVBnRkZmUnhDN0NNV1ZIMWROYl9pTS1BS3kxemI0M2dvIiwiUHhTalYxR1dnRW81RENhWmFWeXpONXRfZ19zWGRyTXFZSHM4blg3QmJOTSIsIl9PWVF4Q1dhYUpXcERJZFltY1FYZmxBUVdKVUN5Q2dwTHZSSUxYSUFOek0iLCJhMy1QR2NmSkJwczg4Y1h5UUFQVkFzUHZKRUVrZUF6TWZYcGRMSTVaTnVFIiwiYW1WNnJLY1p4VGNrWnlkYUt2RmswNUVZZUdza09lbkI1amFKSHp2am1YayIsInJkUW5XNmFGV3phYjAzRVlvMHJJYWpKaHFad2Ewam1tQVE5d3dqWmxKcHciLCJ2VXpEc3dNVnRvSlAxaFl6Y1hHVGdlY2daVFFHbW5mZmFGOUxlT0FCa3RVIiwieVdubU00MDVTMFJLRHNSWmhHT3NNZjhLT3ZPXzNkNExkcXlOWXlqaTdqZyIsInlyZjVZbC1xdjRvdHUycTQxQUtZa2ZqaVJwUzY1enNyaVpnU0dzOGF5ekkiXSwidmN0IjoidXJuOmV1ZGk6cGlkOjEiLCJfc2RfYWxnIjoic2hhLTI1NiIsImlzcyI6Imh0dHBzOi8vZGV2Lmlzc3Vlci1iYWNrZW5kLmV1ZGl3LmRldiIsImNuZiI6eyJqd2siOnsia3R5IjoiRUMiLCJ1c2UiOiJzaWciLCJjcnYiOiJQLTI1NiIsImtpZCI6IjIxNzNkOWUwLTdhNjQtNDNiMi1hOTJlLWE2ZGI5NmViMWJiMyIsIngiOiI5YzRzWGRpSWxHRnI5OUdpWVk1aFpDdGJZSUQwUDVxajJuTmFzMHhOck5BIiwieSI6Im54ekVnRlBQR3lhN0lxbUE3LUpCVENtMFNHN0hzV3ZyLWNlZFFTdDE5RE0iLCJpYXQiOjE3NjA2OTk4NzR9fSwiZXhwIjoxNzYzMjkxODc0LCJpYXQiOjE3NjA2OTk4NzQsInN0YXR1cyI6eyJzdGF0dXNfbGlzdCI6eyJpZHgiOjE2MDQsInVyaSI6Imh0dHBzOi8vaXNzdWVyLmV1ZGl3LmRldi90b2tlbl9zdGF0dXNfbGlzdC9GQy91cm46ZXVkaTpwaWQ6MS9iYTYwYzg3NC04ZWZjLTQ3YWQtYmE3MS02NWE0MjM2MmJiOTUifX19.GBlN9azEAa86YHNKDiRCPGHdTdx57v5JYbS2f8LkeK4b53vlAM_FWTrcOWR8jim-Xi17KMo6NtjeQYp0DmQ29g~WyJIcmEzOVJxckp5SXJmdHFSWGkxNHJBIiwiZmFtaWx5X25hbWUiLCJOZWFsIl0~WyJVYmdTdHBiVmI4ZkZUOWpiQ20tVUhnIiwiZ2l2ZW5fbmFtZSIsIlR5bGVyIl0~WyJRMGRWSlUwYnZ3SU5nMWxlTlV0QXlnIiwiYmlydGhkYXRlIiwiMTk1NS0wNC0xMiJd~WyJRMmZNeTJZMWRFekJzbVBzWXhFeFZRIiwiY291bnRyeSIsIkFUIl0~WyJ5VGVPUGNkdzgzMFk2MjB0WkoySm5BIiwibG9jYWxpdHkiLCIxMDEgVHJhdW5lciJd~WyJMdEpuY2JkYU8ySmlxR3FTOUMxbTVRIiwicGxhY2Vfb2ZfYmlydGgiLHsiX3NkIjpbIkc0bS1BRXdEMDlLSEtLamNjMkJhV2JTMU9Qa0lCZjR6aG53NHcxUTY3NnMiLCJHNHNpUFhUWHo2M29uaWNZMFpiejhpbnlMQnlETG01U3dOWDk2OEJ3RjJVIl19XQ~WyJoTk5tc0Zyd0lBcUl6QWJ4ZmhSYzVRIiwiQVQiXQ~WyJUSURLSndZSnJaLTVhb1ZubXJjMVpRIiwibmF0aW9uYWxpdGllcyIsW3siLi4uIjoiYkNWV3lPNzJ4Uk1FZXNGM19hYmtQQllBV0VCOTdkb0RTZVhkOHNCakc1OCJ9XV0~WyJfM0JTUktCM0Z6cGZkRE1VQ3ltVU1RIiwiaG91c2VfbnVtYmVyIiwiMTAxICJd~WyJvdkwwUmhYbjRNLXpuRE4wTkVqcUR3Iiwic3RyZWV0X2FkZHJlc3MiLCJUcmF1bmVyIl0~WyJyRndKUU5rV1Q4Z0VUcmdWamNWbHVBIiwibG9jYWxpdHkiLCJHZW1laW5kZSBCaWJlcmJhY2giXQ~WyJqZ3JYYkQzLUM5NV9mMkgtSGk2YzRnIiwicmVnaW9uIiwiTG93ZXIgQXVzdHJpYSJd~WyJ3N1pOM2dTdUtkaXhaenZLenFBb1R3IiwicG9zdGFsX2NvZGUiLCIzMzMxIl0~WyJRRVhxT0FRTzNuMklhUUI5WFE4TE1BIiwiY291bnRyeSIsIkFUIl0~WyJMUDd2M3Itam53MDJmSy01bV9mRGV3IiwiYWRkcmVzcyIseyJfc2QiOlsic2R5bl9nZTN3OVZSbUQySjJHTHBqVG1MRG5Va20xWUxtNExKRTZzQ3c1cyIsIjZhaVVFQWo3NE9DU2lobnlCdmN0V29CbHJtQzQ4U3JuYVlzUjFaak16SlkiLCJWWGc2UG9EWUk1Y1ctVXc0UE5JMlgwbkltdmROdTNaMGR6R0ZockE3QjI0IiwibDNJM0o0RHdMYWtJOHNKTVhSYVZ3al9lRFlqRm9WWUZ5cHVoOEF5TWRVZyIsIllDXzl4SkdCWXZPRVZpY1JmejJGVWtFTXpyUXZGdk9hYUx3bU56MEZfMVEiLCJOdE1LUDg4OUNXNlZ3SWV3SXU1WDZ3SGpNTUhYYnNNLXdEQXdaREVsVTB3Il19XQ~WyJtdk9oYkJQMnFNQlpWMzNLcWNWV1lnIiwicGVyc29uYWxfYWRtaW5pc3RyYXRpdmVfbnVtYmVyIiwiMDczMDAzZDMtYzRiOS00YzIwLTljYjgtNTBjMGEzODIwMGJjIl0~WyJYSWpnVmNaMWZTX2pmQTFPNHdQb2ZRIiwiYmlydGhfZmFtaWx5X25hbWUiLCJOZWFsIl0~WyJhVnVaVWxCUnJmdjV4NkJyUFFqVktRIiwiYmlydGhfZ2l2ZW5fbmFtZSIsIlR5bGVyIl0~WyJMY3pWT1dWbXhiOF9FVTdSeVVYb2d3Iiwic2V4IiwxXQ~WyI0SXJ2clJRTmRleE12SllhTExKNktRIiwiZW1haWwiLCJ0eWxlci5uZWFsQGV4YW1wbGUuY29tIl0~WyJKQm1uSERheEl0UDk5R0ZlREwxOHd3IiwiZGF0ZV9vZl9leHBpcnkiLCIyMDI2LTAxLTI1Il0~WyJQWDBveFhQSG01Yk82bHhucndhd3BnIiwiaXNzdWluZ19hdXRob3JpdHkiLCJHUiBBZG1pbmlzdHJhdGl2ZSBhdXRob3JpdHkiXQ~WyI5WXl6aG5kUnRKQVVqRlpqVlNoMlR3IiwiaXNzdWluZ19jb3VudHJ5IiwiR1IiXQ~WyJTUXZyclhxZzQ1LXVpVHBYa3ZpcUV3IiwiZG9jdW1lbnRfbnVtYmVyIiwiNGQwOTRjN2QtOGU5OC00NTQyLTg4ZjUtNTdmZWRhOWM0N2MyIl0~WyJCRDY4RTJnTnEybzQ0R3JiTmhDb2x3IiwiaXNzdWluZ19qdXJpc2RpY3Rpb24iLCJHUi1JIl0~WyJQYWNHbGd2ajBYTkdCQzhpX1lqQWJRIiwiZGF0ZV9vZl9pc3N1YW5jZSIsIjIwMjUtMTAtMTciXQ~"
  
  static let sdJwtVcPidKey = """
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEApNrvFyPbvx4HGWt1u7sx2E1A3TiENG7H7xI6mzqv1eB7vKc3
A9a46wNUVrbulbUkzm9dEAYd1eC+NsbOCp86W27tRo2zuAf8uTzP7b6M+2ehsGU1
fC30CNuKbQqB4nA0sBpOnsVhj8c4g2Chb8VD7E9SGs/htdKYlt8OoVB5Pys+/dSl
l/LWK/pm7oX+rWn2ohw2JTHFYVZry9IOy3KScFGeH4TypKlihOd0l5bTYg38v9ew
WghSJVlaXQVSFFU3Rm1rklWl64wghDsuGQ/4+0cspJMexQviRer189yh8n20LttL
jwNWbpee9VO3VvP6HrzaDdiixX/O4D7XN541fwIDAQABAoIBACGK1EPijWcU/n/L
EBDq9SjcCxsX0Tpz4eVAUcFczwMW4kZPxY9X5JcYvdPI88FtMnh4Szij7fUi/cDa
cXjSzgZliwykb1E9+stb1ri6YSgT/V+NMDU8il81ADTQgv3mM6ozKBUA9ylQcSy2
ABLkUb4mo3+GFZgvqdFkwC7NV2YlHFeLGAtHBqx29DlNaRMKel6ikXjwuhkO/GIa
CIwBSgyKwAWo171JlehsIgrvMKaTvrJzkdQdLkg0nzAs+sjpDuQHpa+xgYHOCxWN
CHkZUyv3t17IjjT0pUAMw8F1Fn6/L87GICzjCo+52uOkAe74ZP7Px4z88MiJI7KA
Zg40P20CgYEA0L/YvKkn6wdFY3XjujsWfUbaYQsXkWsFJXK5GuSKY7cvCFbS8v9e
C2TXuWcag9TXyTZgMEuEkVR8cB1tiS1ov2T48LpCUb/qkk5Pbd5Rea/vQH1GSmb7
aizaDWo4JoRNX8D4R+lO3V52o6m3z8wc9MemW0z7QfWKvFVfqVI8fXsCgYEAyiua
VS9a8fzePQNlkIy2kWGJRG7PpUPi/b0B01TPlqMoKTWocJY/BVcaLP7pOxTA/YTL
5ndz1vuGAZtn2Oph5gxuAYEOMHwA/hPSiwTPcbS0uvK/AwJxdIELOriub/jiMQwo
tIL2IdSO3Go5AzKsyQPeEuu+j0XROYWehKujDs0CgYANG26tceWawUsfEqDo6Zrg
5NkDbOHe9JxPHKP4x07VMgRW/rSiI1yxVHSjJJEqo+ukq7Bgd+1r/qUNmRtumJZS
JjHnU5qkbWt6IkakfGgbPuvD3dnTBCJXKVfLrda2vGnrUD+GrGSSS8MhRZ/QAV30
FLEiXHQOUS+T4bxu8kXwDwKBgQCvT4wvHjdg7APTKKTj6gFOpCOiIe0RxIKLwWBZ
34t7dtQWmB8OMltHyDY8mneo8eBAdu1RVngvDkEwF5C/us9V66VgzIZ/aKh7qrjC
MFOqqCaojmMwuuejPVt9ejRZiJqsKX0Kux2wTF/tpnb13PWUAjSKd77xAnvhw4qo
RSXKaQKBgBuq/2c5H5r1PDtDIiffnG1uhq7J1XXFeEv19aaR651dI4ewhUVmShej
7MddFuVWXS+orbnTXxqoDUJLtRVtvAb7xsbNpsUOVKx/w9CmsRgFY79zABaA2CTh
d82/03tD1U0Slpjr2098V5XpQMeSveb/elCPCohSBt7tBiaN98zc
-----END RSA PRIVATE KEY-----
"""
  
  static func generateMdocGeneratedNonce() -> String {
    var bytes = [UInt8](repeating: 0, count: 16)
    let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    if result != errSecSuccess {
      bytes = (0 ..< 16).map { _ in UInt8.random(in: UInt8.min ... UInt8.max) }
    }
    return Data(bytes).base64URLEncodedString()
  }
  
  public static func testVpFormatsSupportedTO() -> VpFormatsSupportedTO {
    .init(
      vcSdJwt: .init(
        sdJwtAlgorithms: ["PS256"],
        kdJwtAlgorithms: ["PS256"]
      )
    )
  }
  
  static func sdJwtPresentations(
    transactiondata: [TransactionData]?,
    clientID: String,
    nonce: String,
    useSha3: Bool = true
  ) -> String {
    
    let sdHash = useSha3 ? sha3_256Hash(sdJwtVcPid) : sha256Hash(sdJwtVcPid)
    
    return try! generateVerifiablePresentation(
      sdJwtVc: sdJwtVcPid,
      audience: clientID,
      nonce: nonce,
      sdHash: sdHash,
      transactionData: transactiondata
    )
  }
  
  static let x509CertificateChain: [String] = [
    "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"
  ]
  
  static func loadRootCertificates() throws -> [Base64Certificate] {
    let certNames = [
      "pidissuerca02_cz",
      "pidissuerca02_ee",
      "pidissuerca02_eu",
      "pidissuerca02_lu",
      "pidissuerca02_nl",
      "pidissuerca02_pt",
      "pidissuerca02_ut"
    ]
    
    return try certNames.map { name in
      guard let path = Bundle.module.path(forResource: name, ofType: "der") else {
        throw NSError(domain: "CertLoadError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing certificate: \(name)"])
      }
      let data = try Data(contentsOf: URL(fileURLWithPath: path))
      return data.base64EncodedString()
    }
  }
}

func generateVerifiablePresentation(
  sdJwtVc: String,
  audience: String,
  nonce: String,
  sdHash: String,
  transactionData: [TransactionData]?
) throws -> String {
  
  // Create JWT Header
  let header = try! JWSHeader(
    parameters: [
      "alg": "ES256",
      "typ": "kb+jwt"
    ]
  )
  
  let privateKey = createECPrivateSecKey(
    xStr: "9c4sXdiIlGFr99GiYY5hZCtbYID0P5qj2nNas0xNrNA",
    yStr: "nxzEgFPPGya7IqmA7-JBTCm0SG7HsWvr-cedQSt19DM",
    dStr: "60AASOBvKciaWNH_PUReMdZqKkfPvad7zGo3DhhaxUA"
  )
  
  // Prepare claims
  var claims: [String: Any] = [
    "aud": audience,
    "nonce": nonce,
    "iat": Int(Date().timeIntervalSince1970) - 100,
    "sd_hash": sdHash
  ]
  
  // Process transaction data hashes if available
  if let transactionData = transactionData, !transactionData.isEmpty {
    let hashAlgorithm = "sha-256"
    let transactionDataHashes = transactionData.map {
      return sha256Hash($0.value)
    }
    claims["transaction_data_hashes_alg"] = hashAlgorithm
    claims["transaction_data_hashes"] = transactionDataHashes
  }
  
  // Create JWT Payload
  let payloadData = try! JSONSerialization.data(
    withJSONObject: claims,
    options: []
  )
  let payload = Payload(payloadData)
  
  // Sign JWT
  // Create and Sign JWT Using JoseSwift
  let jws = try JWS(
    header: header,
    payload: payload,
    signer: Signer(
      signatureAlgorithm: .ES256,
      key: privateKey!
    )!
  )
  let keyBindingJwt = jws.compactSerializedString
  return "\(sdJwtVc)\(keyBindingJwt)"
}

extension Data {
  func base64URLEncodedString() -> String {
    return self.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "") // Remove padding
  }
}

func sha3_256Hash(_ input: String) -> String {
  let inputData = Array(input.utf8)
  let digest = SHA3(variant: .sha256).calculate(for: inputData)
  return Data(digest).base64URLEncodedString()
}

func sha256Hash(_ input: String) -> String {
  let inputData = Array(input.utf8)
  let digest = SHA256.hash(data: inputData)
  return Data(digest).base64URLEncodedString()
}

func createRSAPrivateSecKey(_ key: String) -> SecKey {
  let keyData = Data(
    base64Encoded: key
      .replacingOccurrences(of: "-----BEGIN RSA PRIVATE KEY-----", with: "")
      .replacingOccurrences(of: "-----END RSA PRIVATE KEY-----", with: "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: "\n", with: "")
  )!
  
  let attributes: [NSObject: NSObject] = [
    kSecAttrKeyType: kSecAttrKeyTypeRSA,
    kSecAttrKeyClass: kSecAttrKeyClassPrivate,
    kSecAttrKeySizeInBits: NSNumber(value: 2048)
  ]
  
  var error: Unmanaged<CFError>?
  let privateKey = SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, &error)!
  
  return privateKey
}

func createECPrivateSecKey(xStr: String, yStr: String, dStr: String) -> SecKey? {
  // Fix padding for Base64URL → Base64
  func fixBase64Padding(_ base64url: String) -> String {
    var base64 = base64url
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")
    let padding = base64.count % 4
    if padding == 2 {
      base64.append("==")
    } else if padding == 3 {
      base64.append("=")
    } else if padding == 1 {
      base64.append("===") // rare case
    }
    return base64
  }
  
  // Decode base64URL strings
  guard let xBytes = Data(base64Encoded: fixBase64Padding(xStr)),
        let yBytes = Data(base64Encoded: fixBase64Padding(yStr)),
        let dBytes = Data(base64Encoded: fixBase64Padding(dStr)) else {
    print("❌ Base64 decoding failed")
    return nil
  }
  
  // Create uncompressed public key format: 0x04 || x || y
  let keyData = NSMutableData(bytes: [0x04], length: 1)
  keyData.append(xBytes)
  keyData.append(yBytes)
  
  // This is just the public key part, but you want a private key, so dBytes must be included in the right format.
  // Append private key d — this by itself doesn't make a valid private key structure,
  // but we are assuming your environment accepts raw private key with appended dBytes.
  keyData.append(dBytes)
  
  // Attributes
  let attributes: [String: Any] = [
    kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
    kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
    kSecAttrKeySizeInBits as String: 256,
    kSecAttrIsPermanent as String: false
  ]
  
  // Create SecKey
  var error: Unmanaged<CFError>?
  guard let keyReference = SecKeyCreateWithData(keyData as CFData,
                                                attributes as CFDictionary,
                                                &error) else {
    print("❌ SecKeyCreateWithData failed:", error!.takeRetainedValue())
    return nil
  }
  
  return keyReference
}

func secKeyFromRSAJWK(_ nBase64: String) throws -> SecKey {

  let eBase64 = "AQAB"
  guard
    let nData = Data(base64URLEncoded: nBase64),
    let eData = Data(base64URLEncoded: eBase64)
  else {
    throw NSError(
      domain: "InvalidBase64",
      code: 8,
      userInfo: [NSLocalizedDescriptionKey: "Failed to decode n or e"]
    )
  }
  
  let rsaKeyData = try encodeRSAPublicKey(modulus: nData, exponent: eData)
  
  let attributes: [String: Any] = [
    kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
    kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
    kSecAttrKeySizeInBits as String: nData.count * 8
  ]
  
  guard let secKey = SecKeyCreateWithData(
    rsaKeyData as CFData,
    attributes as CFDictionary,
    nil
  ) else {
    throw NSError(
      domain: "SecKeyCreationFailed",
      code: 9,
      userInfo: [NSLocalizedDescriptionKey: "Failed to create RSA SecKey"]
    )
  }
  return secKey
}

func encodeRSAPublicKey(
  modulus: Data,
  exponent: Data
) throws -> Data {
  
  let modulusBytes = Array(modulus)
  let exponentBytes = Array(exponent)
  
  let modulusWithLeadingZero = modulusBytes[0] >= 0x80 ? [0x00] + modulusBytes : modulusBytes
  let exponentWithLeadingZero = exponentBytes[0] >= 0x80 ? [0x00] + exponentBytes : exponentBytes
  
  let modulusLength = encodeASN1Length(modulusWithLeadingZero.count)
  let exponentLength = encodeASN1Length(exponentWithLeadingZero.count)
  
  let sequenceLength = encodeASN1Length(1 + modulusLength.count + modulusWithLeadingZero.count + 1 + exponentLength.count + exponentWithLeadingZero.count)
  
  let first: [UInt8] = [0x30] + sequenceLength
  let second: [UInt8] = [0x02] + modulusLength + modulusWithLeadingZero
  let third: [UInt8] = [0x02] + exponentLength + exponentWithLeadingZero
  return Data(first + second + third)
}

// MARK: - ASN.1 Encoding Helpers
func encodeASN1Length(_ length: Int) -> [UInt8] {
  if length < 0x80 {
    return [UInt8(length)]
  } else {
    let lengthBytes = withUnsafeBytes(of: length.bigEndian, Array.init).drop { $0 == 0 }
    return [0x80 | UInt8(lengthBytes.count)] + lengthBytes
  }
}

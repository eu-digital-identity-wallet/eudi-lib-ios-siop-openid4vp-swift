import Foundation
@testable import SiopOpenID4VP

struct TestsConstants {
  
  // MARK: - Client meta data by value, Presentation definition by reference
  
  static let validByClientByValuePresentationByReferenceUrlString =
  "eudi-wallet://authorize?" +
  "response_type=vp_token" +
  "&client_id=MY_CLIENT_ID" +
  "&client_id_scheme=pre-registered" +
  "&client_meta_data={\"jwks_uri\":\"value_jwks_uri\",\"id_token_signed_response_alg\":\"value_id_token_signed_response_alg\",\"id_token_encrypted_response_alg\":\"value_id_token_encrypted_response_alg\",\"id_token_encrypted_response_enc\":\"value_id_token_encrypted_response_enc\",\"subject_syntax_types_supported\":[\"value_subject_syntax_types_supported\"]}" +
  "&redirect_uri=https://client.example.org/redirect_me" +
  "&presentation_definition_uri=https://us-central1-dx4b-4c2d8.cloudfunctions.net/api_ecommbx/presentation_definition/32f54163-7166-48f1-93d8-ff217bdb0653" +
  "&nonce=n-0S6_WzA2Mj" +
  "&response_mode=direct_post" +
  "&response_uri=https://client.example.org/response"
  
  static var validByClientByValuePresentationByReferenceUrl: URL {
    return URL(string: validByClientByValuePresentationByReferenceUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    )!
  }
  
  // MARK: - Client meta data by reference, Presentation definition by reference
  
  static let validByClientByReferencePresentationByReferenceUrlString =
  "eudi-wallet://authorize?" +
  "response_type=vp_token" +
  "&client_id=MY_CLIENT_ID" +
  "&client_id_scheme=pre-registered" +
  "&client_meta_data_uri=https://client.example.org/redirect_me" +
  "&redirect_uri=https://client.example.org/redirect_me" +
  "&presentation_definition_uri=https://us-central1-dx4b-4c2d8.cloudfunctions.net/api_ecommbx/presentation_definition/32f54163-7166-48f1-93d8-ff217bdb0653" +
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
  "eudi-wallet://authorized?request_uri=https://us-central1-dx4b-4c2d8.cloudfunctions.net/api_ecommbx/request_jwt/mock_001"
  
  static var requestUriUrl: URL {
    return URL(string: requestUriUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
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
  "&client_id=https://client.example.org/" +
  "&client_id_scheme=pre-registered" +
  "&redirect_uri=https://client.example.org/" +
  "&presentation_definition=%@" +
  "&nonce=n-0S6_WzA2Mj"
  
  static var nonNormativeOutOfScopeUrlString =
  "https://www.example.com/authorize?" +
  "response_type=vp_token" +
  "&client_id=https://client.example.org/" +
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
    // TODO: use definitition, not container
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
}

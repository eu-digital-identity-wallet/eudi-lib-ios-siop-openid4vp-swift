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

internal actor ClientMetaDataValidator {
  
  func validate(clientMetaData: ClientMetaData) async throws -> ClientMetaData.Validated? {
    
    let idTokenJWSAlg: JWSAlgorithm = .init(
      name: try clientMetaData.idTokenSignedResponseAlg ?? { throw ValidatedAuthorizationError.validationError("idTokenSignedResponseAlg is nil") }()
    )
    
    let idTokenJWEAlg: JWEAlgorithm = .init(
      name: try clientMetaData.idTokenEncryptedResponseAlg ?? { throw ValidatedAuthorizationError.validationError("idTokenEncryptedResponseAlg is nil") }()
    )
    
    let idTokenJWEEnc: JOSEEncryptionMethod = .init(
      name: try clientMetaData.idTokenEncryptedResponseEnc ?? { throw ValidatedAuthorizationError.validationError("idTokenEncryptedResponseEnc is nil") }()
    )
    
    let subjectSyntaxTypesSupported: [SubjectSyntaxType] = clientMetaData.subjectSyntaxTypesSupported.compactMap { SubjectSyntaxType(rawValue: $0) }
    
    if !clientMetaData.authorizationEncryptedResponseAlg.isNilOrEmpty && clientMetaData.authorizationEncryptedResponseEnc.isNilOrEmpty {
      throw ValidatedAuthorizationError.validationError("authorizationEncryptedResponseAlg exists, authorizationEncryptedResponseEnc does not exist, both should exist")
      
    } else if clientMetaData.authorizationEncryptedResponseAlg.isNilOrEmpty && !clientMetaData.authorizationEncryptedResponseEnc.isNilOrEmpty {
      throw ValidatedAuthorizationError.validationError("authorizationEncryptedResponseAlg does not exist, authorizationEncryptedResponseEnc exists, both should exist")
    }
    
    let validated = await ClientMetaData.Validated(
      jwkSet: try extractKeySet(clientMetaData: clientMetaData),
      idTokenJWSAlg: idTokenJWSAlg,
      idTokenJWEAlg: idTokenJWEAlg,
      idTokenJWEEnc: idTokenJWEEnc,
      subjectSyntaxTypesSupported: subjectSyntaxTypesSupported,
      authorizationSignedResponseAlg: parseOptionJWSAlgorithm(algorithm: clientMetaData.authorizationSignedResponseAlg),
      authorizationEncryptedResponseAlg: parseOptionJWEAlgorithm(algorithm: clientMetaData.authorizationEncryptedResponseAlg),
      authorizationEncryptedResponseEnc: parseOptionEncryptionAlgorithm(algorithm: clientMetaData.authorizationEncryptedResponseEnc)
    )
    
    return validated
  }
}

private extension ClientMetaDataValidator {
  
  func parseOptionJWSAlgorithm(algorithm: String?) -> JWSAlgorithm? {
    guard let algorithm = algorithm else { return nil }
    return .init(
      name: algorithm
    )
  }
  
  func parseOptionJWEAlgorithm(algorithm: String?) -> JWEAlgorithm? {
    guard let algorithm = algorithm else { return nil }
    return .init(
      name: algorithm
    )
  }
  
  func parseOptionEncryptionAlgorithm(algorithm: String?) -> JOSEEncryptionMethod? {
    guard let algorithm = algorithm else { return nil }
    return .init(
      name: algorithm
    )
  }
  
  func extractKeySet(clientMetaData: ClientMetaData) async throws -> WebKeySet {
    
    if let jwks = clientMetaData.jwks,
       let keys = try jwks.convertToDictionary() {
      return try WebKeySet(keys)
      
    } else if let jwksUri = clientMetaData.jwksUri,
              let uri = URL(string: jwksUri) {
      let webKeyResolver = WebKeyResolver()
      let response = await webKeyResolver.resolve(source: .fetchByReference(url: uri))
      
      switch response {
      case .success(let webKeys):
        return try webKeys ?? { throw ValidatedAuthorizationError.validationError("Client meta data has no valid JWK source") }()
      default: throw ValidatedAuthorizationError.validationError("Client meta data has no valid JWK source")
      }
      
    } else {
      throw ValidatedAuthorizationError.validationError("Client meta data has no valid JWK source")
    }
  }
}

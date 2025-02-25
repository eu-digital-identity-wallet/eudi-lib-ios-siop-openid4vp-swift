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
import SwiftyJSON

internal actor ClientMetaDataValidator {
  
  @discardableResult
  func validate(clientMetaData: ClientMetaData?) async throws -> ClientMetaData.Validated? {
    
    guard let clientMetaData = clientMetaData else {
      return nil
    }
    
    let idTokenJWSAlg: JWSAlgorithm? = parseOptionJWSAlgorithm(algorithm: clientMetaData.idTokenSignedResponseAlg)
    
    let idTokenJWEAlg: JWEAlgorithm? = .init(
      optionalName: clientMetaData.idTokenEncryptedResponseAlg
    )
    
    let idTokenJWEEnc: JOSEEncryptionMethod? = .init(
      optionalName: clientMetaData.idTokenEncryptedResponseEnc
    )
    
    let subjectSyntaxTypesSupported: [SubjectSyntaxType] = clientMetaData.subjectSyntaxTypesSupported.compactMap { SubjectSyntaxType(rawValue: $0) }
    
    if !clientMetaData.authorizationEncryptedResponseAlg.isNilOrEmpty && clientMetaData.authorizationEncryptedResponseEnc.isNilOrEmpty {
      throw ValidationError.validationError("authorizationEncryptedResponseAlg exists, authorizationEncryptedResponseEnc does not exist, both should exist")
      
    } else if clientMetaData.authorizationEncryptedResponseAlg.isNilOrEmpty && !clientMetaData.authorizationEncryptedResponseEnc.isNilOrEmpty {
      throw ValidationError.validationError("authorizationEncryptedResponseAlg does not exist, authorizationEncryptedResponseEnc exists, both should exist")
    }
    
    let formats = try? VpFormats(from: clientMetaData.vpFormats)
    let validated = await ClientMetaData.Validated(
      jwkSet: try extractKeySet(clientMetaData: clientMetaData),
      idTokenJWSAlg: idTokenJWSAlg,
      idTokenJWEAlg: idTokenJWEAlg,
      idTokenJWEEnc: idTokenJWEEnc,
      subjectSyntaxTypesSupported: subjectSyntaxTypesSupported,
      authorizationSignedResponseAlg: parseOptionJWSAlgorithm(algorithm: clientMetaData.authorizationSignedResponseAlg),
      authorizationEncryptedResponseAlg: parseOptionJWEAlgorithm(algorithm: clientMetaData.authorizationEncryptedResponseAlg),
      authorizationEncryptedResponseEnc: .init(optionalSupportedName: clientMetaData.authorizationEncryptedResponseEnc),
      vpFormats: try (formats ?? VpFormats.empty())
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
       let keys = try? JSON(jwks.convertToDictionary() ?? [:]) {
      return try WebKeySet(keys)
      
    } else if let jwksUri = clientMetaData.jwksUri,
              let uri = URL(string: jwksUri) {
      let webKeyResolver = WebKeyResolver()
      let response = await webKeyResolver.resolve(source: .fetchByReference(url: uri))
      
      switch response {
      case .success(let webKeys):
        return try webKeys ?? { throw ValidationError.validationError("Client meta data has no valid JWK source") }()
      default: throw ValidationError.validationError("Client meta data has no valid JWK source")
      }
      
    } else {
      throw ValidationError.validationError("Client meta data has no valid JWK source")
    }
  }
}

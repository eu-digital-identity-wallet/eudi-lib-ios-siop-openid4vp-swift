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
  func validate(
    clientMetaData: ClientMetaData?,
    responseMode: ResponseMode?,
    responseEncryptionConfiguration: ResponseEncryptionConfiguration
  ) async throws -> ClientMetaData.Validated? {

    guard let clientMetaData = clientMetaData else {
      return nil
    }

    let keySet = try? await extractKeySet(clientMetaData: clientMetaData)
    let formats = try? VpFormatsSupported(from: clientMetaData.vpFormatsSupported)
    let supported = try responseEncryptionMethodsSupported(
      unvalidated: clientMetaData
    )
    let responseEncryptionSpecification = try responseEncryptionSpecification(
      responseMode: responseMode,
      verifierSupportedEncryptionMethods: supported,
      keySet: keySet,
      responseEncryptionConfiguration: responseEncryptionConfiguration
    )
    
    let validated = ClientMetaData.Validated(
      jwkSet: keySet,
      vpFormatsSupported: try (formats ?? VpFormatsSupported.empty()),
      responseEncryptionSpecification: responseEncryptionSpecification
    )

    return validated
  }
}

private extension ClientMetaDataValidator {

  func responseEncryptionSpecification(
    responseMode: ResponseMode?,
    verifierSupportedEncryptionMethods: [EncryptionMethod]?,
    keySet: WebKeySet?,
    responseEncryptionConfiguration: ResponseEncryptionConfiguration
  ) throws -> ResponseEncryptionSpecification? {
    if let responseMode {
      if !responseMode.requiresEncryption() {
        if verifierSupportedEncryptionMethods == nil {
          return nil
        } else {
          throw ValidationError.validationError(
            "\(RESPONSE_ENCRYPTION_METHODS_SUPPORTED) must not be provided when encryption is not required"
          )
        }
      } else {
        if let keySet = keySet {
          let verifierCandidateEncryptionKeys = keySet.keys
            .filter { key in
              !(key.kid?.isEmpty ?? true) && !(key.alg?.isEmpty ?? true)
          }
          return try createResponseEncryptionSpecification(
            walletConfiguration: responseEncryptionConfiguration,
            verifierCandidateEncryptionKeys: WebKeySet(
              keys: verifierCandidateEncryptionKeys
            ),
            verifierSupportedEncryptionMethods: verifierSupportedEncryptionMethods ?? DEFAULT_RESPONSE_ENCRYPTION_METHODS
          )
        } else {
          throw ValidationError.validationError(
            "\(JWKS) must be provided when encryption is required"
          )
        }
      }
    } else {
      return nil
    }
  }
  
  private func createResponseEncryptionSpecification(
    walletConfiguration: ResponseEncryptionConfiguration,
    verifierCandidateEncryptionKeys: WebKeySet,
    verifierSupportedEncryptionMethods: [EncryptionMethod]
  ) throws -> ResponseEncryptionSpecification {
    
    guard !verifierCandidateEncryptionKeys.keys.isEmpty else {
      throw ValidationError.validationError(
        "No encryption JWKs were advertised by the Verifier in his Client Metadata"
      )
    }
    
    guard !verifierSupportedEncryptionMethods.isEmpty else {
      throw ValidationError.validationError(
        "No encryption methods were advertised by the Verifier in his Client Metadata"
      )
    }
    
    guard let encryptionMethod = walletConfiguration.supportedMethods.first(where: {
      verifierSupportedEncryptionMethods.contains($0)
    }) else {
      throw ValidationError.validationError(
        "Wallet doesn't support any of the encryption methods supported by Verifier"
      )
    }
    
    switch walletConfiguration {
    case .supported(
      _,
      _
    ):
      guard let (encryptionAlgorithm, encryptionKey) = walletConfiguration.supportedAlgorithms.compactMap({ supportedAlgorithm -> (JWEAlgorithm, WebKeySet.Key)? in
        if let encryptionKey = verifierCandidateEncryptionKeys.keys.first(where: { key in
          supportedAlgorithm.name == key.alg
          }) {
              return (supportedAlgorithm, encryptionKey)
          } else {
              return nil
          }
      }).first else {
        throw ValidationError.validationError(
          "Wallet doesn't support any of the encryption algorithms supported by verifier"
        )
      }

      return ResponseEncryptionSpecification(
        responseEncryptionAlg: encryptionAlgorithm,
        responseEncryptionEnc: encryptionMethod,
        clientKey: WebKeySet(
          keys: [encryptionKey]
        )
      )
    case .unsupported:
      throw ValidationError.validationError(
        "Wallet doesn't support encrypting authorization responses"
      )
    }
  }
  
  func responseEncryptionMethodsSupported(
    unvalidated: ClientMetaData
  ) throws -> [EncryptionMethod]? {
      
    let methods: [EncryptionMethod]? = unvalidated.responseEncryptionMethodsSupported?.map {
      .parse($0)
    }
      
    if let methods = methods {
      if methods.isEmpty {
        throw ValidationError.validationError(
          "\(RESPONSE_ENCRYPTION_METHODS_SUPPORTED) must not be empty"
        )
      }
    }
    return methods
  }
  
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

    } else {
      throw ValidationError.validationError("Client meta data has no valid JWK source")
    }
  }
}

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

public enum ValidationError: AuthorizationRequestError, Equatable {
  case validationError(String)
  case unsupportedClientIdScheme(String?)
  case unsupportedResponseType(String?)
  case unsupportedResponseMode(String?)
  case unsupportedIdTokenType(String?)
  case invalidResponseType
  case invalidIdTokenType
  case noAuthorizationData
  case invalidAuthorizationData
  case invalidConfiguration
  case invalidPresentationDefinition
  case invalidClientMetadata
  case invalidJWTWebKeySet
  case missingRequiredField(String?)
  case invalidJwtPayload
  case invalidRequestUri(String?)
  case invalidRequest
  case conflictingData
  case notSupportedOperation
  case invalidFormat
  case unsupportedConsent
  case negativeConsent
  case clientIdMismatch(String?, String?)
  case invalidClientId
  case invalidJarmOption
  case invalidJarmClientMetadata
  case invalidWalletConfiguration
  case unsupportedAlgorithm(String?)
  case invalidSigningKey
  case emptyValue
  case multipleQuerySources
  case invalidQuerySource
  case invalidUri
  case invalidRequestUriMethod
  case invalidUseOfBothRequestAndRequestUri
  case missingClientId
  case missingConfiguration
  case missingResponseType
  case missingNonce
  
  public var errorDescription: String? {
    switch self {
    case .validationError(let message):
      return "Validation Error \(message)"
    case .unsupportedClientIdScheme(let scheme):
      return ".unsupportedClientIdScheme \(scheme ?? "")"
    case .unsupportedResponseType(let type):
      return ".unsupportedResponseType \(String(describing: type))"
    case .unsupportedResponseMode(let mode):
      return ".unsupportedResponseMode \(mode ?? "")"
    case .unsupportedIdTokenType(let type):
      return ".unsupportedIdTokenType \(type ?? "")"
    case .invalidResponseType:
      return ""
    case .invalidIdTokenType:
      return ".invalidResponseType"
    case .noAuthorizationData:
      return ".noAuthorizationData"
    case .invalidAuthorizationData:
      return "invalidAuthorizationData"
    case .invalidConfiguration:
      return "invalidConfiguration"
    case .invalidPresentationDefinition:
      return ".invalidAuthorizationData"
    case .invalidClientMetadata:
      return ".invalidClientMetadata"
    case .invalidJWTWebKeySet:
      return ".invalidJWTWebKeySet"
    case .missingRequiredField(let field):
      return ".missingRequiredField \(field ?? "")"
    case .invalidJwtPayload:
      return ".invalidJwtPayload"
    case .invalidRequestUri(let uri):
      return ".invalidRequestUri \(uri ?? "")"
    case .conflictingData:
      return ".conflictingData"
    case .invalidRequest:
      return ".invalidRequest"
    case .notSupportedOperation:
      return ".notSupportedOperation"
    case .invalidFormat:
      return ".invalidFormat"
    case .unsupportedConsent:
      return ".unsupportedConsent"
    case .negativeConsent:
      return ".negativeConsent"
    case .clientIdMismatch(let lhs, let rhs):
      return ".clientIdMismatch \(String(describing: lhs)) \(String(describing: rhs))"
    case .invalidClientId:
      return ".invalidClientId"
    case .invalidJarmOption:
      return ".invalidJarmOption"
    case .invalidJarmClientMetadata:
      return ".invalidJarmClientMetadata"
    case .invalidWalletConfiguration:
      return ".invalidWalletConfiguration"
    case .unsupportedAlgorithm(let algorithm):
      return "unsupportedAlgorithm \(algorithm ?? "-")"
    case .invalidSigningKey:
      return ".invalidSigningKey"
    case .emptyValue:
      return ".emptyValue"
    case .multipleQuerySources:
      return ".multipleQuerySources"
    case .invalidQuerySource:
      return ".invalidQuerySource"
    case .invalidUri:
      return ".invalidUri"
    case .invalidRequestUriMethod:
      return ".invalidRequestUriMethod"
    case .invalidUseOfBothRequestAndRequestUri:
      return ".invalidUseOfBothRequestAndRequestUri"
    case .missingClientId:
      return ".missingClientId"
    case .missingConfiguration:
      return ".missingConfiguration"
    case .missingResponseType:
      return ".missingResponseType"
    case .missingNonce:
      return ".missingNonce"
    }
  }
}

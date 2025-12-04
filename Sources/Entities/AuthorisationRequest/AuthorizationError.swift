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

/// An enumeration representing errors that can occur during authorization.
public enum AuthorizationError: LocalizedError {
  /// The response type is unsupported.
  case unsupportedResponseType(type: String)

  /// The response type is missing.
  case missingResponseType

  /// The URL scheme is unsupported.
  case unsupportedURLScheme

  /// The resolution is unsupported.
  case unsupportedResolution

  /// The state is invalid.
  case invalidState

  /// The nonce is invalid.
  case invalidNonce

  /// The response mode is invalid.
  case invalidResponseMode

  /// Request and request uri both exist.
  case invalidUseOfBothRequestAndRequestUri

  /// Unsupported method.
  case unsupportedRequestUriMethod(method: RequestUriMethod)

  /// Invalid method
  case invalidRequestUriMethod

  /// Invalid transaction data
  case invalidTransactionData

  /// Non dispatchable error.
  case nonDispatchableError

  /// JWT decryption failed.
  case jwtDecryptionFailed

  /// Invalid algorithms.
  case invalidAlgorithms

  /// A localized description of the error.
  public var errorDescription: String? {
    switch self {
    case .unsupportedResponseType(let type):
      return ".unsupportedResponseType \(type)"
    case .missingResponseType:
      return ".invalidScopes"
    case .unsupportedURLScheme:
      return ".unsupportedURLScheme"
    case .unsupportedResolution:
      return ".unsupportedResolution"
    case .invalidState:
      return ".invalidState"
    case .invalidNonce:
      return ".invalidNonce"
    case .invalidResponseMode:
      return ".invalidResponseMode"
    case .invalidUseOfBothRequestAndRequestUri:
      return ".invalidUseOfBothRequestAndRequestUri"
    case .unsupportedRequestUriMethod(let method):
      return ".unsupportedRequestUriMethod\(method)"
    case .invalidRequestUriMethod:
      return ".invalidRequestUriMethod"
    case .invalidTransactionData:
      return ".invalidTransactionData"
    case .nonDispatchableError:
      return ".nonDispatchableError"
    case .jwtDecryptionFailed:
      return ".jwtDecryptionFailed"
    case .invalidAlgorithms:
      return ".invalidAlgorithms"
    }
  }
}

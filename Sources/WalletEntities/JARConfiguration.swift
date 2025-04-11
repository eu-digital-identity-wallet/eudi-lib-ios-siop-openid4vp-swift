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

public struct JARConfiguration: Sendable {
  public let supportedAlgorithms: [JWSAlgorithm]
  public let supportedRequestUriMethods: SupportedRequestUriMethod
  
  /// Initializer with validation to ensure supportedAlgorithms is not empty
  public init(
    supportedAlgorithms: [JWSAlgorithm],
    supportedRequestUriMethods: SupportedRequestUriMethod = .defaultOption
  ) {
    precondition(!supportedAlgorithms.isEmpty, "JAR signing algorithms cannot be empty")
    self.supportedAlgorithms = supportedAlgorithms
    self.supportedRequestUriMethods = supportedRequestUriMethods
  }
  
  /// Default JAR configuration with trusted algorithms ES256, ES384, and ES512
  public static let `default` = JARConfiguration(
    supportedAlgorithms: [
      JWSAlgorithm(
        .ES256
      )
    ],
    supportedRequestUriMethods: .defaultOption
  )
}

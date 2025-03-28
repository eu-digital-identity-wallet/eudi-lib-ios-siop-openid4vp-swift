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

public enum SupportedRequestUriMethod {
  case get
  case post(
    postOptions: PostOptions
  )
  case both(
    post: PostOptions
  )
  
  public init?(method: String, includeWalletMetadata: Bool = true, useWalletNonce: NonceOption = .use(byteLength: 32)) {
    switch method.uppercased() {
    case "GET":
      self = .get
    case "POST":
      self = .post(postOptions: .init(
        includeWalletMetadata: includeWalletMetadata,
        useWalletNonce: useWalletNonce
      ))
    default:
      return nil // Invalid input returns nil
    }
  }
  
  public struct PostOptions {
    public let includeWalletMetadata: Bool
    public let useWalletNonce: NonceOption
    
    public init(includeWalletMetadata: Bool, useWalletNonce: NonceOption) {
      self.includeWalletMetadata = includeWalletMetadata
      self.useWalletNonce = useWalletNonce
    }
  }
  
  /// Method to check if `get` is supported
  public func isGetSupported() -> Bool {
    switch self {
    case .get, .both:
      return true
    case .post:
      return false
    }
  }
  
  /// Method to check if `post` is supported
  public func isPostSupported() -> PostOptions? {
    switch self {
    case .both(let postOptions):
      return postOptions
    case .post(let options):
      return options
    case .get:
      return nil
    }
  }
  
  /// Default instance
  public static let defaultOption: SupportedRequestUriMethod = .both(
    post: PostOptions(
      includeWalletMetadata: true,
      useWalletNonce: NonceOption.doNotUse
    )
  )
}


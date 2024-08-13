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
import JOSESwift

public struct VerifierAttestationClaims {
  public let iss: String
  public let sub: String
  public let iat: Date?
  public let exp: Date
  public let verifierPubJwk: JWK
  public let redirectUris: [String]?
  public let responseUris: [String]?
    
  public init(
    iss: String,
    sub: String,
    iat: Date?,
    exp: Date,
    verifierPubJwk: JWK,
    redirectUris: [String]?,
    responseUris: [String]?
  ) {
    self.iss = iss
    self.sub = sub
    self.iat = iat
    self.exp = exp
    self.verifierPubJwk = verifierPubJwk
    self.redirectUris = redirectUris
    self.responseUris = responseUris
  }
}

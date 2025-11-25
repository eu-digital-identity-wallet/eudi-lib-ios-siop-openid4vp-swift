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

/**
 Consent. Holder decided to respond to a request
  */
public enum ClientConsent {

  /**
   In response to an OpenId4VPAuthorization where the wallet has claims that fulfill Verifier's presentation definition
    - Parameters:
     - vpToken the vp_token to be included in the authorization response
    */
  case vpToken(
    vpContent: VpContent
  )

  /**
   No consensus. Holder decided to reject the request
    */
  case negative(message: String)
}

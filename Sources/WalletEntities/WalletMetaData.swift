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

// Function to create wallet metadata
public func walletMetaData(cfg: SiopOpenId4VPConfiguration) -> JSON {
  var json = JSON()
  
  // JAR related
  json[REQUEST_OBJECT_SIGNING_ALG_VALUES_SUPPORTED] = JSON(cfg.jarConfiguration.supportedAlgorithms.map { $0.name })
  
  // OpenIdVP
  json[PRESENTATION_DEFINITION_URI_SUPPORTED] = JSON(cfg.vpConfiguration.presentationDefinitionUriSupported)
  
  json[VP_FORMATS_SUPPORTED] = cfg.vpConfiguration.vpFormats.toJSON()["vp_formats"]
  
  json[CLIENT_ID_SCHEMES_SUPPORTED] = JSON(cfg.supportedClientIdSchemes.map { $0.name })
  
  // Response types supported
  json[RESPONSE_TYPES_SUPPORTED] = JSON(["vp_token", "id_token"])
  
  // Response modes supported
  json[RESPONSE_MODES_SUPPORTED] = JSON(["direct_post", "direct_post.jwt"])
  
  return json
}

// Constants (these should be declared at the top level)
private let REQUEST_OBJECT_SIGNING_ALG_VALUES_SUPPORTED = "request_object_signing_alg_values_supported"
private let AUTHORIZATION_SIGNING_ALG_VALUES_SUPPORTED = "authorization_signing_alg_values_supported"
private let AUTHORIZATION_ENCRYPTION_ALG_VALUES_SUPPORTED = "authorization_encryption_alg_values_supported"
private let AUTHORIZATION_ENCRYPTION_ENC_VALUES_SUPPORTED = "authorization_encryption_enc_values_supported"
private let PRESENTATION_DEFINITION_URI_SUPPORTED = "presentation_definition_uri_supported"
private let CLIENT_ID_SCHEMES_SUPPORTED = "client_id_schemes_supported"
private let VP_FORMATS_SUPPORTED = "vp_formats_supported"
private let RESPONSE_TYPES_SUPPORTED = "response_types_supported"
private let RESPONSE_MODES_SUPPORTED = "response_modes_supported"


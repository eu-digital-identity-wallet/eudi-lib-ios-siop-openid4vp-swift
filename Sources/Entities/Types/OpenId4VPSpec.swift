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
public struct OpenId4VPSpec {
  public static let clientIdSchemeSeparator: Character = ":"
  public static let clientIdSchemePreRegistered = "pre-registered"
  public static let clientIdSchemeRedirectUri = "redirect_uri"
  public static let clientIdSchemeHttps = "https"
  public static let clientIdSchemeDid = "did"
  public static let clientIdSchemeX509SanUri = "x509_san_uri"
  public static let clientIdSchemeX509SanDns = "x509_san_dns"
  public static let clientIdSchemeVerifierAttestation = "verifier_attestation"
  
  public static let TRANSACTION_DATA_TYPE = "transaction_data_type"
  public static let TRANSACTION_DATA_CREDENTIAL_IDS = "transaction_data_credential_ids"
  public static let TRANSACTION_DATA_HASH_ALGORITHMS = "transaction_data_hash_algorithms"
}


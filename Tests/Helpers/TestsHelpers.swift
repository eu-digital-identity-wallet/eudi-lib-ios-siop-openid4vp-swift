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

@testable import SiopOpenID4VP

class TestsHelpers {
  static func getDirectPostSession(
    nonce: String
  ) async throws -> [String: Any] {
    
    // Replace this URL with the endpoint you want to send the POST request to
    let url = URL(string: "\(TestsConstants.host)/ui/presentations")!
    
    // Create a POST request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // Set the request body data (e.g., JSON data)
    let jsonBody = [
      "type": "id_token",
      "id_token_type": "subject_signed_id_token",
      "nonce": nonce
    ]
    
    let jsonData = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
    request.httpBody = jsonData
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
  }
  
  static func getDirectPostJwtSession(
    nonce: String
  ) async throws -> [String: Any] {
    
    // Replace this URL with the endpoint you want to send the POST request to
    let url = URL(string: "\(TestsConstants.host)/ui/presentations")!
    
    // Create a POST request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // Set the request body data (e.g., JSON data)
    let jsonBody = [
      "type": "vp_token",
      "response_mode":  "direct_post.jwt",
      "nonce": nonce,
      "presentation_definition_mode": "by_reference",
      "presentation_definition": [
        "id": "32f54163-7166-48f1-93d8-ff217bdb0653",
        "input_descriptors": []
      ]
    ] as [String : Any]
    
    let jsonData = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
    request.httpBody = jsonData
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let (data, _) = try await URLSession.shared.data(for: request)
    return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
  }
  
  static func pollVerifier(presentationId: String, nonce: String) async throws -> Result<String, FetchError>{
    let fetcher = Fetcher<String>()
    let pollingUrl = URL(string: "\(TestsConstants.host)/ui/presentations/\(presentationId)?nonce=\(nonce)")!
    return try await fetcher.fetchString(url: pollingUrl)
  }
}

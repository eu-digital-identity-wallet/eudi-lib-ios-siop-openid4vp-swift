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
import XCTest
@testable import SiopOpenID4VP

import SwiftyJSON

final class DCQLTests: XCTestCase {

  override func setUpWithError() throws {
  }

  override func tearDownWithError() throws {
  }

  func testOne() throws {
      
    let dcqlString = """
    {
      "credentials": [
        {
          "id": "my_credential",
          "format": "dc+sd-jwt",
          "meta": {
            "vct_values": [ "https://credentials.example.com/identity_credential" ]
          },
          "claims": [
            {"path": ["last_name"]},
            {"path": ["first_name"]},
            {"path": ["address", "street_address"]}
          ]
        }
      ]
    }
    """
    
    let data = dcqlString.data(using: .utf8)!
    let json = try! JSON(data: data)
      
    do {
      let dcql = try DCQL(from: json)
      print(dcql)
      
    } catch {
      print(error)
    }
  }
  
  func testTwo() throws {
      
    let dcqlString = """
    {
      "credentials": [
        {
          "id": "eu_europa_ec_eudi_pid_1",
          "format": "vc+sd-jwt",
          "meta": {
            "vct_values": [ "urn:eu.europa.ec.eudi:pid:1" ]
          },
          "claims": [
            {
              "path": [ "family_name" ]
            }
          ]
        }
      ]
    }
    """
    
    let data = dcqlString.data(using: .utf8)!
    let json = try! JSON(data: data)
      
    do {
      let dcql = try DCQL(from: json)
      print(dcql)
      
    } catch {
      print(error)
    }
  }
  
  func testThree() throws {
      
    let dcqlString = """
    {
      "credentials": [
        {
          "id": "eu_europa_ec_eudi_pid_1",
          "format": "mso_mdoc",
          "meta": {
            "doctype_value": "eu.europa.ec.eudi.pid.1"
          },
          "claims": [
            {
              "namespace": "eu.europa.ec.eudi.pid.1",
              "claim_name": "family_name"
            }
          ]
        }
      ]
    }
    """
    
    let data = dcqlString.data(using: .utf8)!
    let json = try! JSON(data: data)
      
    do {
      let dcql = try DCQL(from: json)
      print(dcql)
      
    } catch {
      print(error)
    }
  }
}

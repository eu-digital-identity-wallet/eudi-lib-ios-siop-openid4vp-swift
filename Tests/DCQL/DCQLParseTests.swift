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

final class DCQLParseTests: XCTestCase {
  
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
      XCTAssert(true)
      
    } catch {
      print(error)
      XCTAssert(false)
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
      XCTAssert(true)
      
    } catch {
      print(error)
      XCTAssert(false)
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
      XCTAssert(true)
      
    } catch {
      print(error)
      XCTAssert(false)
    }
  }
  
  func testComplex() throws {
    
    let dcqlString = """
    {
      "credentials": [
        {
          "id": "mdl-id",
          "format": "mso_mdoc",
          "meta": {
            "doctype_value": "org.iso.18013.5.1.mDL"
          },
          "claims": [
            {
              "id": "given_name",
              "path": ["org.iso.18013.5.1", "given_name"]
            },
            {
              "id": "family_name",
              "path": ["org.iso.18013.5.1", "family_name"]
            },
            {
              "id": "portrait",
              "path": ["org.iso.18013.5.1", "portrait"]
            }
          ]
        },
        {
          "id": "mdl-address",
          "format": "mso_mdoc",
          "meta": {
            "doctype_value": "org.iso.18013.5.1.mDL"
          },
          "claims": [
            {
              "id": "resident_address",
              "path": ["org.iso.18013.5.1", "resident_address"]
            },
            {
              "id": "resident_country",
              "path": ["org.iso.18013.5.1", "resident_country"]
            }
          ]
        },
        {
          "id": "photo_card-id",
          "format": "mso_mdoc",
          "meta": {
            "doctype_value": "org.iso.23220.photoid.1"
          },
          "claims": [
            {
              "id": "given_name",
              "path": ["org.iso.18013.5.1", "given_name"]
            },
            {
              "id": "family_name",
              "path": ["org.iso.18013.5.1", "family_name"]
            },
            {
              "id": "portrait",
              "path": ["org.iso.18013.5.1", "portrait"]
            }
          ]
        },
        {
          "id": "photo_card-address",
          "format": "mso_mdoc",
          "meta": {
            "doctype_value": "org.iso.23220.photoid.1"
          },
          "claims": [
            {
              "id": "resident_address",
              "path": ["org.iso.18013.5.1", "resident_address"]
            },
            {
              "id": "resident_country",
              "path": ["org.iso.18013.5.1", "resident_country"]
            }
          ]
        }
      ],
      "credential_sets": [
        {
          "purpose": "Identification",
          "options": [
            [ "mdl-id" ],
            [ "photo_card-id" ]
          ]
        },
        {
          "purpose": "Proof of address",
          "required": false,
          "options": [
            [ "mdl-address" ],
            [ "photo_card-address" ]
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
      XCTAssert(true)
      
    } catch {
      print(error)
      XCTAssert(false)
    }
  }
  
  func testParse() throws {
    
    let jsonString = """
    {
      "credentials": [
        {
          "id": "my_credential",
          "format": "mso_mdoc",
          "meta": {
            "doctype_value": "org.iso.7367.1.mVRC"
          },
          "claims": [
            {
              "namespace": "org.iso.7367.1",
              "claim_name": "vehicle_holder"
            },
            {
              "namespace": "org.iso.18013.5.1",
              "claim_name": "first_name"
            }
          ]
        }
      ]
    }
    """
    let data = jsonString.data(using: .utf8)!
    let json = try! JSON(data: data)
    let primary = try DCQL(from: json)
    
    let secondary = try DCQL(
      credentials: [
        .mdoc(
          id: .init(value: "my_credential"),
          msoMdocMeta: .init(
            doctypeValue: .init(value: "org.iso.7367.1.mVRC")
          ),
          claims: [
            .mdoc(
              namespace: .init("org.iso.7367.1"),
              claimName: .init(claimName: "vehicle_holder")
            ),
            .mdoc(
              namespace: .init("org.iso.18013.5.1"),
              claimName: .init(claimName: "first_name")
            )
          ]
        )
      ]
    )
    
    print("**********\(primary == secondary)")
  }
  
  func testWhenMsoMdocNamespaceMissesAnExceptionThrown() throws {
    
    let jsonString = """
    {
      "credentials": [
        {
          "id": "my_credential",
          "format": "mso_mdoc",
          "meta": {
            "doctype_value": "org.iso.7367.1.mVRC"
          },
          "claims": [
            {
              "claim_name": "vehicle_holder"
            },
            {
              "namespace": "org.iso.18013.5.1",
              "claim_name": "first_name"
            }
          ]
        }
      ]
    }
    """
    let data = jsonString.data(using: .utf8)!
    let json = try! JSON(data: data)
    
    do {
      let _ = try DCQL(from: json)
      XCTAssert(false)
    } catch {
      XCTAssert(error is DecodingError, "Namespace must be present when claim name is present")
    }
  }
  
  func testWhenMsoMdocClaimNameMissingExceptionThrown() throws {
    
    let jsonString = """
    {
      "credentials": [
        {
          "id": "my_credential",
          "format": "mso_mdoc",
          "meta": {
            "doctype_value": "org.iso.7367.1.mVRC"
          },
          "claims": [
            {
              "namespace": "org.iso.18013.5.1"
            }
          ]
        }
      ]
    }
    """
    let data = jsonString.data(using: .utf8)!
    let json = try! JSON(data: data)
    
    do {
      let _ = try DCQL(from: json)
      XCTAssert(false)
    } catch {
      XCTAssert(error is DecodingError, "Claim name must be present when namespace is present")
    }
  }
  
  func test01() throws {
    let jsonString = """
    {
      "credentials": [
        {
          "id": "my_credential",
          "format": "mso_mdoc",
          "meta": {
            "doctype_value": "org.iso.7367.1.mVRC"
          },
          "claims": [
            {
              "namespace": "org.iso.7367.1",
              "claim_name": "vehicle_holder"
            },
            {
              "namespace": "org.iso.18013.5.1",
              "claim_name": "first_name"
            }
          ]
        }
      ]
    }
    """
    
    let data = jsonString.data(using: .utf8)!
    let json = try! JSON(data: data)
    let primary = try DCQL(from: json)
    
    let secondary = try! DCQL(
      credentials: .init([
        .mdoc(
          id: .init(value: "my_credential"),
          msoMdocMeta: .init(
            doctypeValue: .init(
              value: "org.iso.7367.1.mVRC"
            )
          ),
          claims: [
            .mdoc(
              namespace: .init("org.iso.7367.1"),
              claimName: .init(claimName: "vehicle_holder")
            ),
            .mdoc(
              namespace: .init("org.iso.18013.5.1"),
              claimName: .init(claimName: "first_name")
            )
          ]
        ),
      ])
    )
    XCTAssert(primary == secondary)
  }
  
  func test02() async throws {
    let jsonString = """
    {
      "credentials": [
        {
          "id": "pid",
          "format": "dc+sd-jwt",
          "meta": {
            "vct_values": ["https://credentials.example.com/identity_credential"]
          },
          "claims": [
            {"path": ["given_name"]},
            {"path": ["family_name"]},
            {"path": ["address", "street_address"]}
          ]
        },
        {
          "id": "mdl",
          "format": "mso_mdoc",
          "meta": {
            "doctype_value": "org.iso.7367.1.mVRC"
          },
          "claims": [
            {
              "namespace": "org.iso.7367.1",
              "claim_name": "vehicle_holder"
            },
            {
              "namespace": "org.iso.18013.5.1",
              "claim_name": "first_name"
            }
          ]
        }
      ]
    }
    """
    
    let data = jsonString.data(using: .utf8)!
    let json = try! JSON(data: data)
    let primary = try DCQL(from: json)
    
    let secondary = try! DCQL(
      credentials: [
        CredentialQuery.sdJwtVc(
          id: .init(value: "pid"),
          sdJwtVcMeta: .init(vctValues: ["https://credentials.example.com/identity_credential"]),
          claims: [
            ClaimsQuery.sdJwtVc(
              path: ClaimPath.claim("given_name")
            ),
            ClaimsQuery.sdJwtVc(
              path: ClaimPath.claim("family_name")
            ),
            ClaimsQuery.sdJwtVc(
              path: ClaimPath.claim("address").claim("street_address")
            )
          ]
        ),
        CredentialQuery.mdoc(
          id: .init(value: "mdl"),
          msoMdocMeta: .init(doctypeValue: .init(value: "org.iso.7367.1.mVRC")),
          claims: [
            ClaimsQuery.mdoc(
              namespace: .init("org.iso.7367.1"),
              claimName: .init(claimName: "vehicle_holder")
            ),
            ClaimsQuery.mdoc(
              namespace: .init("org.iso.18013.5.1"),
              claimName: .init(claimName: "first_name")
            )
          ]
        )
      ]
    )
    
    XCTAssert(primary == secondary)
  }
  
  func test03() async throws {
    let jsonString = """
    {
      "credentials": [
        {
          "id": "pid",
          "format": "dc+sd-jwt",
          "meta": {
            "vct_values": ["https://credentials.example.com/identity_credential"]
          },
          "claims": [
            {"path": ["given_name"]},
            {"path": ["family_name"]},
            {"path": ["address", "street_address"]}
          ]
        },
        {
          "id": "other_pid",
          "format": "dc+sd-jwt",
          "meta": {
            "vct_values": ["https://othercredentials.example/pid"]
          },
          "claims": [
            {"path": ["given_name"]},
            {"path": ["family_name"]},
            {"path": ["address", "street_address"]}
          ]
        },
        {
          "id": "pid_reduced_cred_1",
          "format": "dc+sd-jwt",
          "meta": {
            "vct_values": ["https://credentials.example.com/reduced_identity_credential"]
          },
          "claims": [
            {"path": ["given_name"]},
            {"path": ["family_name"]}
          ]
        },
        {
          "id": "pid_reduced_cred_2",
          "format": "dc+sd-jwt",
          "meta": {
            "vct_values": ["https://cred.example/residence_credential"]
          },
          "claims": [
            {"path": ["postal_code"]},
            {"path": ["locality"]},
            {"path": ["region"]}
          ]
        },
        {
          "id": "nice_to_have",
          "format": "dc+sd-jwt",
          "meta": {
            "vct_values": ["https://company.example/company_rewards"]
          },
          "claims": [
            {"path": ["rewards_number"]}
          ]
        }
      ],
      "credential_sets": [
        {
          "purpose": "Identification",
          "options": [
            [ "pid" ],
            [ "other_pid" ],
            [ "pid_reduced_cred_1", "pid_reduced_cred_2" ]
          ]
        },
        {
          "purpose": "Show your rewards card",
          "required": false,
          "options": [
            [ "nice_to_have" ]
          ]
        }
      ]
    }
    """
    let data = jsonString.data(using: .utf8)!
    let json = try! JSON(data: data)
    let primary = try DCQL(from: json)
    
    let secondary = try! DCQL.init(
      credentials: [
        .sdJwtVc(
          id: .init(value: "pid"),
          sdJwtVcMeta: .init(vctValues: [
            "https://credentials.example.com/identity_credential"
          ]),
          claims: [
            .sdJwtVc(path: .claim("given_name")),
            .sdJwtVc(path: .claim("family_name")),
            .sdJwtVc(path: .claim("address").claim("street_address"))
          ]
        ),
        .sdJwtVc(
          id: .init(value: "other_pid"),
          sdJwtVcMeta: .init(vctValues: [
            "https://othercredentials.example/pid"
          ]),
          claims: [
            .sdJwtVc(path: .claim("given_name")),
            .sdJwtVc(path: .claim("family_name")),
            .sdJwtVc(path: .claim("address").claim("street_address"))
          ]
        ),
        .sdJwtVc(
          id: .init(value: "pid_reduced_cred_1"),
          sdJwtVcMeta: .init(vctValues: [
            "https://credentials.example.com/reduced_identity_credential"
          ]),
          claims: [
            .sdJwtVc(path: .claim("given_name")),
            .sdJwtVc(path: .claim("family_name"))
          ]
        ),
        .sdJwtVc(
          id: .init(value: "pid_reduced_cred_2"),
          sdJwtVcMeta: .init(vctValues: [
            "https://cred.example/residence_credential"
          ]),
          claims: [
            .sdJwtVc(path: .claim("postal_code")),
            .sdJwtVc(path: .claim("locality")),
            .sdJwtVc(path: .claim("region"))
          ]
        ),
        .sdJwtVc(
          id: .init(value: "nice_to_have"),
          sdJwtVcMeta: .init(vctValues: [
            "https://company.example/company_rewards"
          ]),
          claims: [
            .sdJwtVc(path: .claim("rewards_number"))
          ]
        )
      ],
      credentialSets: [
        .init(
          options: [
            [.init(value: "pid")],
            [.init(value: "other_pid")],
            [.init(value: "pid_reduced_cred_1"), .init(value: "pid_reduced_cred_2")]
          ],
          purpose: .init("Identification")
        ),
        .init(
          options: [
            [.init(value: "nice_to_have")]
          ],
          required: false,
          purpose: .init("Show your rewards card")
        )
      ]
    )
    
    XCTAssert(primary == secondary)
  }
  
  func test04() throws {
    
    let jsonString = """
    {
      "credentials": [
        {
          "id": "mdl-id",
          "format": "mso_mdoc",
          "meta": {
            "doctype_value": "org.iso.18013.5.1.mDL"
          },
          "claims": [
            {
              "id": "given_name",
              "namespace": "org.iso.18013.5.1",
              "claim_name": "given_name"
            },
            {
              "id": "family_name",
              "namespace": "org.iso.18013.5.1",
              "claim_name": "family_name"
            },
            {
              "id": "portrait",
              "namespace": "org.iso.18013.5.1",
              "claim_name": "portrait"
            }
          ]
        },
        {
          "id": "mdl-address",
          "format": "mso_mdoc",
          "meta": {
            "doctype_value": "org.iso.18013.5.1.mDL"
          },
          "claims": [
            {
              "id": "resident_address",
              "namespace": "org.iso.18013.5.1",
              "claim_name": "resident_address"
            },
            {
              "id": "resident_country",
              "namespace": "org.iso.18013.5.1",
              "claim_name": "resident_country"
            }
          ]
        },
        {
          "id": "photo_card-id",
          "format": "mso_mdoc",
          "meta": {
            "doctype_value": "org.iso.23220.photoid.1"
          },
          "claims": [
            {
              "id": "given_name",
              "namespace": "org.iso.23220.1",
              "claim_name": "given_name"
            },
            {
              "id": "family_name",
              "namespace": "org.iso.23220.1",
              "claim_name": "family_name"
            },
            {
              "id": "portrait",
              "namespace": "org.iso.23220.1",
              "claim_name": "portrait"
            }
          ]
        },
        {
          "id": "photo_card-address",
          "format": "mso_mdoc",
          "meta": {
            "doctype_value": "org.iso.23220.photoid.1"
          },
          "claims": [
            {
              "id": "resident_address",
              "namespace": "org.iso.23220.1",
              "claim_name": "resident_address"
            },
            {
              "id": "resident_country",
              "namespace": "org.iso.23220.1",
              "claim_name": "resident_country"
            }
          ]
        }
      ],
      "credential_sets": [
        {
          "purpose": "Identification",
          "options": [
            [ "mdl-id" ],
            [ "photo_card-id" ]
          ]
        },
        {
          "purpose": "Proof of address",
          "required": false,
          "options": [
            [ "mdl-address" ],
            [ "photo_card-address" ]
          ]
        }
      ]
    }
    """
    
    let data = jsonString.data(using: .utf8)!
    let json = try! JSON(data: data)
    let primary = try DCQL(from: json)
    
    let secondary = try! DCQL(
      credentials: [
        .mdoc(
          id: .init(value: "mdl-id"),
          msoMdocMeta: .init(
            doctypeValue: .init(
              value: "org.iso.18013.5.1.mDL"
            )
          ),
          claims: [
            .mdoc(
              id: .init("given_name"),
              namespace: .init("org.iso.18013.5.1"),
              claimName: .init(claimName: "given_name")
            ),
            .mdoc(
              id: .init("family_name"),
              namespace: .init("org.iso.18013.5.1"),
              claimName: .init(claimName: "family_name")
            ),
            .mdoc(
              id: .init("portrait"),
              namespace: .init("org.iso.18013.5.1"),
              claimName: .init(claimName: "portrait")
            ),
          ]
        ),
        .mdoc(
          id: .init(value: "mdl-address"),
          msoMdocMeta: .init(
            doctypeValue: .init(
              value: "org.iso.18013.5.1.mDL"
            )
          ),
          claims: [
            .mdoc(
              id: .init("resident_address"),
              namespace: .init("org.iso.18013.5.1"),
              claimName: .init(claimName: "resident_address")
            ),
            .mdoc(
              id: .init("resident_country"),
              namespace: .init("org.iso.18013.5.1"),
              claimName: .init(claimName: "resident_country")
            )
          ]
        ),
        .mdoc(
          id: .init(value: "photo_card-id"),
          msoMdocMeta: .init(
            doctypeValue: .init(
              value: "org.iso.23220.photoid.1"
            )
          ),
          claims: [
            .mdoc(
              id: .init("given_name"),
              namespace: .init("org.iso.23220.1"),
              claimName: .init(claimName: "given_name")
            ),
            .mdoc(
              id: .init("family_name"),
              namespace: .init("org.iso.23220.1"),
              claimName: .init(claimName: "family_name")
            ),
            .mdoc(
              id: .init("portrait"),
              namespace: .init("org.iso.23220.1"),
              claimName: .init(claimName: "portrait")
            ),
          ]
        ),
        .mdoc(
          id: .init(value: "photo_card-address"),
          msoMdocMeta: .init(
            doctypeValue: .init(
              value: "org.iso.23220.photoid.1"
            )
          ),
          claims: [
            .mdoc(
              id: .init("resident_address"),
              namespace: .init("org.iso.23220.1"),
              claimName: .init(claimName: "resident_address")
            ),
            .mdoc(
              id: .init("resident_country"),
              namespace: .init("org.iso.23220.1"),
              claimName: .init(claimName: "resident_country")
            )
          ]
        )
      ],
      credentialSets: [
        .init(
          options: [
            [.init(value: "mdl-id")],
            [.init(value: "photo_card-id")]
          ],
          purpose: .init("Identification")
        ),
        .init(
          options: [
            [.init(value: "mdl-address")],
            [.init(value: "photo_card-address")]
          ],
          required: false,
          purpose: .init("Proof of address")
        )
      ]
    )
    
    XCTAssert(primary == secondary)
  }
  
  func test05() throws {
    let jsonString = """
    {
      "credentials": [
        {
          "id": "pid",
          "format": "dc+sd-jwt",
          "meta": {
            "vct_values": [ "https://credentials.example.com/identity_credential" ]
          },
          "claims": [
            {"id": "a", "path": ["last_name"]},
            {"id": "b", "path": ["postal_code"]},
            {"id": "c", "path": ["locality"]},
            {"id": "d", "path": ["region"]},
            {"id": "e", "path": ["date_of_birth"]}
          ],
          "claim_sets": [
            ["a", "c", "d", "e"],
            ["a", "b", "e"]
          ]
        }
      ]
    }
    """
    
    let data = jsonString.data(using: .utf8)!
    let json = try! JSON(data: data)
    let primary = try DCQL(from: json)
    
    let secondary = try! DCQL(
      credentials: [
        .sdJwtVc(
          id: .init(value: "pid"),
          sdJwtVcMeta: .init(vctValues: [
            "https://credentials.example.com/identity_credential"
          ]),
          claims: [
            .sdJwtVc(
              id: .init("a"),
              path: .claim("last_name")
            ),
            .sdJwtVc(
              id: .init("b"),
              path: .claim("postal_code")
            ),
            .sdJwtVc(
              id: .init("c"),
              path: .claim("locality")
            ),
            .sdJwtVc(
              id: .init("d"),
              path: .claim("region")
            ),
            .sdJwtVc(
              id: .init("e"),
              path: .claim("date_of_birth")
            )
          ],
          claimSets: [
            [.init("a"), .init("c"), .init("d"), .init("e")],
            [.init("a"), .init("b"), .init("e")]
          ]
        )
      ]
    )
  }
}

import XCTest
import JSONSchema
import Sextant

@testable import SiopOpenID4VP

final class CoreTests: XCTestCase {
  
  func testInputDescriptorResourcesExists() throws {
    let url = Bundle.module.url(forResource: "input-descriptor", withExtension: "json")
    XCTAssertNotNil(url)
  }
  
  func testValidateBasicExampleAgainstSchema() throws {
    
    var schema: [String: Any] = [:]
    var definition: [String: Any] = [:]
    
    let schemaResult = Dictionary.from(localJSONfile: "presentation-definition-envelope")
    switch schemaResult {
    case .success(let envelope):
      schema = envelope
    case .failure(let error):
      XCTAssert(false, error.localizedDescription)
    }
    
    let definitionResult = Dictionary.from(localJSONfile: "basic_example")
    switch definitionResult {
    case .success(let example):
      definition = example
    case .failure(let error):
      XCTAssert(false, error.localizedDescription)
    }
    
    let errors = try! validate(
      definition,
      schema: schema
    ).errors
    
    XCTAssertNil(errors)
  }
  
  func testValidateMdlExampleAgainstSchema() throws {
    
    var schema: [String: Any] = [:]
    var definition: [String: Any] = [:]
    
    let schemaResult = Dictionary.from(localJSONfile: "presentation-definition-envelope")
    switch schemaResult {
    case .success(let envelope):
      schema = envelope
    case .failure(let error):
      XCTAssert(false, error.localizedDescription)
    }
    
    let definitionResult = Dictionary.from(localJSONfile: "mdl_example")
    switch definitionResult {
    case .success(let example):
      definition = example
    case .failure(let error):
      XCTAssert(false, error.localizedDescription)
    }
    
    let errors = try? validate(
      definition,
      schema: schema
    ).errors
    
    XCTAssertNil(errors)
  }
  
  func testValidateMinimalExampleAgainstSchema() throws {
    
    let schema = try? Dictionary.from(
      localJSONfile: "presentation-definition-envelope"
    ).get()
    
    let definition = try? Dictionary.from(
      localJSONfile: "minimal_example"
    ).get()
    
    guard
      let schema = schema,
      let definition = definition
    else {
      XCTAssert(false)
      return
    }
    
    let errors = try! validate(
      definition,
      schema: schema
    ).errors
    
    XCTAssertNil(errors)
  }
  
  func testSimpleDecodableJSONPath() {
      let json = #"{"data":{"people":[{"name":"Rocco","age":42},{"name":"John","age":12},{"name":"Elizabeth","age":35},{"name":"Victoria","age":85}]}}"#
      
      class Person: Decodable {
          let name: String
          let age: Int
      }
      
      guard let persons: [Person] = json.query("$..[?(@.name)]") else { return XCTFail() }
      XCTAssertEqual(persons[0].name, "Rocco")
      XCTAssertEqual(persons[0].age, 42)
      XCTAssertEqual(persons[2].name, "Elizabeth")
      XCTAssertEqual(persons[2].age, 35)
  }
  
  func testPresentationMatcherGivenMatchingClaims() {
    let matcher = PresentationMatcher()
    let parser = Parser()
    let result: Result<PresentationDefinitionContainer, ParserError> = parser.decode(
      path: "basic_example",
      type: "json"
    )
    
    guard let container = try? result.get() else {
      XCTAssert(false, "Unable to decode presentation definition")
      return
    }
    
    let passportClaim = Claim(
      id: "samplePassport",
      jsonObject: [
        "credentialSchema":
          [
            "id": "hub://did:foo:123/Collections/schema.us.gov/passport.json"
          ],
        "credentialSubject":
          [
            "birth_date":"1974-02-11",
          ]
        ]
      )
    
    let bankAccountClaim = Claim(
      id: "sampleBankAccount",
      jsonObject: [
        "credentialSchema":
          [
            "id": "hub://did:foo:123/Collections/schema.us.gov/passport.json"
          ],
        "credentialSubject":
          [
            "account_number":"1234-5678",
          ]
        ]
      )
    
    let match = matcher.match(presentationDefinition: container.definition, claims: [
      passportClaim,
      bankAccountClaim
      ]
    )
    
    if case .found = match {
      XCTAssert(true)
    } else {
      XCTFail("wrong match")
    }
  }
  
  func testPresentationMatcherGivenNonMatchingClaims() {
    let matcher = PresentationMatcher()
    let parser = Parser()
    let result: Result<PresentationDefinitionContainer, ParserError> = parser.decode(
      path: "basic_example",
      type: "json"
    )
    
    guard let container = try? result.get() else {
      XCTAssert(false, "Unable to decode presentation definition")
      return
    }
    
    let nonMatchingClaim = Claim(
      id: "samplePassport",
      jsonObject: [
        "squadName": "Super hero squad",
        "homeTown": "Metro City",
        "formed": 2016,
        "secretBase": "Super tower",
        "active": true,
        "members": [
          "member-one"
        ]
      ]
    )
    
    let match = matcher.match(presentationDefinition: container.definition, claims: [
      nonMatchingClaim
      ]
    )
    
    if case .notFound = match {
      XCTAssert(true)
    } else {
      XCTFail("wrong match")
    }
  }
  
  func testFetcherCodableDecodingGivenValidRemoteURL() async {
    
    struct TestCodable: Codable {
      let title: String
    }
    
    let fetcher = Fetcher<TestCodable>()
    let result = await fetcher.fetch(url: URL(string: "https://jsonplaceholder.typicode.com/todos/1")!)
    let test = try! result.get()
    XCTAssert(test.title == "delectus aut autem")
  }
}

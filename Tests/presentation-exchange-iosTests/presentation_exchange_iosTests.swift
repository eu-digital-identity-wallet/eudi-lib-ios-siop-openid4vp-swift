import XCTest
import JSONSchema
import Sextant

@testable import presentation_exchange_ios

final class presentation_exchange_iosTests: XCTestCase {
  
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
  
  func testPresentationDefinitionDecoding() throws {
    
    let parser = Parser()
    let result: Result<PresentationDefinitionContainer, ParserError> = parser.decode(
      path: "input_descriptors_example",
      type: "json"
    )
    
    let container = try? result.get()
    guard
      let container = container
    else {
      XCTAssert(false)
      return
    }
    
    XCTAssert(container.definition.id == "32f54163-7166-48f1-93d8-ff217bdb0653")
    XCTAssert(true)
  }
  
  func testValidatePresentationDefinitionAgainstSchema() throws {
    
    let schema = try! Dictionary.from(
      localJSONfile: "presentation-definition-envelope"
    ).get()
    
    let parser = Parser()
    let result: Result<PresentationDefinitionContainer, ParserError> = parser.decode(
      path: "input_descriptors_example",
      type: "json"
    )
    
    let container = try! result.get()
    let definition = try! DictionaryEncoder().encode(container.definition)
    
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
  
  func testPresentationMatcher() {
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
    
    let match = matcher.match(pd: container.definition, claims: [
      Claim(
        id: "samplePassport",
        jsonObject: [
          "credentialSchema":
            [
              "id": "hub://did:foo:123/Collections/schema.us.gov/passport.json"
            ],
          "credentialSubject":
            [
              "birth_date":"1974-02-11"
            ]
          ]
        )
      ]
    )
    
    XCTAssertTrue(!match.isEmpty)
  }
}

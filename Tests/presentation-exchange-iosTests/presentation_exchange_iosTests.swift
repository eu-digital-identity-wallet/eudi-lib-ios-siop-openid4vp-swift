import XCTest
import JSONSchema
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
}

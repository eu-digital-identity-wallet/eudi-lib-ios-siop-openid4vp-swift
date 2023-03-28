import XCTest
import JSONSchema
@testable import presentation_exchange_ios

final class presentation_exchange_iosTests: XCTestCase {
  
  func testInputDescriptorResourcesExists() throws {
    let url = Bundle.module.url(forResource: "input-descriptor", withExtension: "json")
    XCTAssertNotNil(url)
  }
  
  func testValidateAgainstBasicExampleSchema() throws {
    
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
}

import XCTest
import JSONSchema
import Sextant
import JOSESwift

@testable import SiopOpenID4VP

final class JOSETests: XCTestCase {
  
  override func setUp() async throws {
    overrideDependencies()
    try await super.setUp()
  }
  
  
  override func tearDown() {
    DependencyContainer.shared.removeAll()
    super.tearDown()
  }
  
  func testJOSEStuff() throws {
    
    let helper = JOSEHelper()
    
    let key = try helper.generateRandomPublicKey()
    print(key)
    
    let jws = try helper.jwtLoop()
    print(jws.compactSerializedString)
  }
}

private extension JOSETests {
  func overrideDependencies() {
    DependencyContainer.shared.register(type: Reporting.self, dependency: {
      Reporter()
    })
  }
}

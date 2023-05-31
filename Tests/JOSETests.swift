import XCTest
import JSONSchema
import Sextant
import JOSESwift

@testable import SiopOpenID4VP

final class JOSETests: XCTestCase {
  
  override func setUp() async throws {

    try await super.setUp()
  }

  override func tearDown() {
    DependencyContainer.shared.removeAll()
    super.tearDown()
  }
  
  func testJOSEStuff() throws {
    

  }
}



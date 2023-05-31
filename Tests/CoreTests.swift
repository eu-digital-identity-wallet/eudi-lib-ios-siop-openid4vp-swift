import XCTest
import JSONSchema
import Sextant

@testable import SiopOpenID4VP

final class CoreTests: XCTestCase {
  
  override func setUp() async throws {
    overrideDependencies()
    try await super.setUp()
  }
  
  override func tearDown() {
    DependencyContainer.shared.removeAll()
    super.tearDown()
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
  
  func testFetcherCodableFailureDecodingGivenInvalidRemoteURL() async {
    
    struct TestCodable: Codable {
      let title: String
    }
    
    let fetcher = Fetcher<TestCodable>()
    let result = await fetcher.fetch(url: URL(string: "https://example.com")!)
    switch result {
    case .failure(let error):
      switch error {
      case .decodingError:
        XCTAssert(true)
        return
      default: break
      }
    default: break
    }
    XCTAssert(false)
  }
}

private extension CoreTests {
  func overrideDependencies() {
    DependencyContainer.shared.register(type: Reporting.self, dependency: {
      MockReporter()
    })
  }
}

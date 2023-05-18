import XCTest
import JSONSchema
import Sextant

@testable import SiopOpenID4VP

final class CoreTests: XCTestCase {
  
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

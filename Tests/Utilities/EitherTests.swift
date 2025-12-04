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
import Foundation
import XCTest

@testable import OpenID4VP

struct Cat: Codable, Equatable {
  let meow: String
}

struct Dog: Codable, Equatable {
  let bark: String
}

final class EitherTests: XCTestCase {

  func testDecodeCat() throws {
    let json = #"{"meow":"purr"}"#.data(using: .utf8)!
    let decoded = try JSONDecoder().decode(Either<Cat, Dog>.self, from: json)

    switch decoded {
    case .left(let cat):
      XCTAssertEqual(cat.meow, "purr")
    case .right:
      XCTFail("Expected .left (Cat), got .right")
    }
  }

  func testDecodeDog() throws {
    let json = #"{"bark":"woof"}"#.data(using: .utf8)!
    let decoded = try JSONDecoder().decode(Either<Cat, Dog>.self, from: json)

    switch decoded {
    case .right(let dog):
      XCTAssertEqual(dog.bark, "woof")
    case .left:
      XCTFail("Expected .right (Dog), got .left")
    }
  }

  func testInvalidJson() {
    let json = #"{"quack":"duck"}"#.data(using: .utf8)!

    XCTAssertThrowsError(try JSONDecoder().decode(Either<Cat, Dog>.self, from: json)) { error in
      guard case DecodingError.typeMismatch = error else {
        return XCTFail("Expected typeMismatch error, got \(error)")
      }
    }
  }

  func testAmbiguousJsonPrefersLeft() throws {
    struct FlexibleCat: Codable {
      let sound: String
    }
    struct FlexibleDog: Codable {
      let sound: String
    }

    let json = #"{"sound":"hi"}"#.data(using: .utf8)!
    let decoded = try JSONDecoder().decode(Either<FlexibleCat, FlexibleDog>.self, from: json)

    switch decoded {
    case .left(let cat):
      XCTAssertEqual(cat.sound, "hi")
    case .right:
      XCTFail("Expected .left (FlexibleCat), got .right")
    }
  }
}

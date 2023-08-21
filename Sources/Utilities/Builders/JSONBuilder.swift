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

protocol JSONBuilderElement {
  var json: String { get }
}

struct Obj: JSONBuilderElement {
  var fragments: [JSONBuilderElement]

  init(fragments: [JSONBuilderElement]) {
    self.fragments = fragments
  }

  init(@JSONBuilder fragments: () -> Self) {
    self = fragments()
  }

  var json: String {
    let contents = fragments
        .map { $0.json }
        .joined(separator: ", ")

    return "{\(contents)}"
  }
}

struct Arr: JSONBuilderElement {
  var fragments: [JSONBuilderElement]

  init(fragments: [JSONBuilderElement]) {
    self.fragments = fragments
  }

  init(@JSONBuilder fragments: () -> Self) {
    self = fragments()
  }

  var json: String {
    let contents = fragments
        .map { $0.json }
        .joined(separator: ", ")

    return "[\(contents)]"
  }
}

struct Key: JSONBuilderElement {
  let key: String
  let value: JSONBuilderElement?

  init(_ key: String, _ value: JSONBuilderElement?) {
    self.key = key
    self.value = value
  }

  var json: String {
    let jsonValue = value?.json ?? "null"

    return "\"\(key)\": \(jsonValue)"
  }
}

extension String: JSONBuilderElement {
  var json: String {
    "\"\(self)\""
  }
}

extension Int: JSONBuilderElement {
  var json: String {
    "\(self)"
  }
}

extension Double: JSONBuilderElement {
  var json: String {
    "\(self)"
  }
}

extension Bool: JSONBuilderElement {
  var json: String {
    "\(self)"
  }
}

/// Result Builder
@resultBuilder
struct JSONBuilder {
    typealias Component = [JSONBuilderElement] // The internal type used to compose things together
    typealias Expression = JSONBuilderElement // One thing - String, JSON object, JSON array etc.

    static func buildBlock(_ components: Component...) -> Component {
      print("- buildBlock for: \(components)")
      return components.flatMap { $0 }
    }

    static func buildExpression(_ expression: Expression) -> Component {
      print("- buildExpression (Expression) for: \(expression)")
      return [expression]
    }

    static func buildArray(_ components: [Component]) -> Component {
      print("- buildArray for: \(components)")
      return components.flatMap { $0 }
    }

    static func buildOptional(_ component: Component?) -> Component {
      print("- buildOptional for: \(String(describing: component))")
      return component ?? []
    }

    static func buildExpression(_ expression: [Expression]) -> Component {
      print("- buildExpression ([Expression]) for: \(expression)")
      return [Arr(fragments: expression)]
    }

    static func buildEither(first component: Component) -> Component {
      print("- buildEither (first) for: \(component)")
      return component
    }

    static func buildEither(second component: Component) -> Component {
      print("- buildEither (second) for: \(component)")
      return component
    }

    static func buildFinalResult(_ component: Component) -> Obj {
      print("- buildFinalResult (Object) for: \(component)")
      return Obj(fragments: component)
    }

    static func buildFinalResult(_ component: Component) -> Arr {
      print("- buildFinalResult (Arr) for: \(component)")
      return Arr(fragments: component)
    }

    static func buildLimitedAvailability(_ component: [JSONBuilderElement]) -> [JSONBuilderElement] {
      print("- buildLimitedAvailability for: \(component)")
      return component
    }
}

@JSONBuilder var jsonTest: Obj {
  Key("example_bool", true)
  Key("example_int", 10)
  Key("example_double", 20.23)
  Key("example_string", "hello world")

  Key("example_object", Obj {
    Key("example_object_key", Key("example_string", "hello world"))
  })

  Key("asdasd", Arr(fragments: [
    "Hello",
    "World!"
  ]))
}

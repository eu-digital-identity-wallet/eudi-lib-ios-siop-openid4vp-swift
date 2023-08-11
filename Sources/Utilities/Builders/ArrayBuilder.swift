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

@resultBuilder
enum ArrayBuilder<OutputModel> {

  static func buildEither(first component: [OutputModel]) -> [OutputModel] {
    return component
  }

  static func buildEither(second component: [OutputModel]) -> [OutputModel] {
    return component
  }

  static func buildOptional(_ component: [OutputModel]?) -> [OutputModel] {
    return component ?? []
  }

  static func buildExpression(_ expression: OutputModel) -> [OutputModel] {
    return [expression]
  }

  static func buildExpression(_ expression: ()) -> [OutputModel] {
    return []
  }

  static func buildBlock(_ components: [OutputModel]...) -> [OutputModel] {
    return components.flatMap { $0 }
  }

  static func buildArray(_ components: [[OutputModel]]) -> [OutputModel] {
    Array(components.joined())
  }
}

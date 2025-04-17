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
import SwiftyJSON

public extension PresentationDefinitionSource {
  init(authorizationRequestObject: JSON) throws {
    if let presentationDefinitionObject = authorizationRequestObject[Constants.PRESENTATION_DEFINITION].dictionaryObject {

      let jsonData = try JSONSerialization.data(withJSONObject: presentationDefinitionObject, options: [])
      let presentationDefinition = try JSONDecoder().decode(PresentationDefinition.self, from: jsonData)

      self = .passByValue(presentationDefinition: presentationDefinition)
    } else if let uri = authorizationRequestObject[Constants.PRESENTATION_DEFINITION_URI].string,
              let uri = URL(string: uri) {
      self = .fetchByReference(url: uri)
    } else if let presentationDefinitionString = authorizationRequestObject[Constants.PRESENTATION_DEFINITION].string {
      
      guard let jsonData = presentationDefinitionString.data(using: .utf8) else {
        throw PresentationError.invalidPresentationDefinition
      }
      
      if let container = try? JSONDecoder().decode(PresentationDefinitionContainer.self, from: jsonData) {
        self = .passByValue(presentationDefinition: container.definition)
      } else {
        let definition = try JSONDecoder().decode(PresentationDefinition.self, from: jsonData)
        self = .passByValue(presentationDefinition: definition)
      }
      
    } else if let scope = authorizationRequestObject[Constants.SCOPE].string,
              !scope.components(separatedBy: " ").isEmpty {
      self = .implied(scope: scope.components(separatedBy: " "))

    } else {

      throw PresentationError.invalidPresentationDefinition
    }
  }

  init(authorizationRequestData: UnvalidatedRequestObject) throws {
    if let presentationDefinitionString = authorizationRequestData.presentationDefinition {
      guard
        presentationDefinitionString.isValidJSONString
      else {
        throw PresentationError.invalidPresentationDefinition
      }

      let parser = Parser()
      let result: Result<PresentationDefinitionContainer, ParserError> = parser.decode(
        json: presentationDefinitionString
      )
      guard
        let presentationDefinition = try? result.get().definition
      else {
        throw PresentationError.invalidPresentationDefinition
      }
      self = .passByValue(presentationDefinition: presentationDefinition)
    } else if let presentationDefinitionUri = authorizationRequestData.presentationDefinitionUri,
              let uri = URL(string: presentationDefinitionUri) {
      self = .fetchByReference(url: uri)
    } else if let scopes = authorizationRequestData.scope?.components(separatedBy: " "),
              !scopes.isEmpty {
      self = .implied(scope: scopes)
    } else {

      throw PresentationError.invalidPresentationDefinition
    }
  }
}

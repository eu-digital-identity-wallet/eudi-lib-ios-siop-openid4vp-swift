import Foundation

enum PresentationDefinitionSource: Codable {
  case passByValue(presentationDefinition: PresentationDefinition)
  case fetchByReference(url: URL)
  case scopes(scopes: [String])
}

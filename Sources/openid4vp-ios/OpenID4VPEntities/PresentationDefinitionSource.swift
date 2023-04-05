import Foundation

public enum PresentationDefinitionSource {
  case passByValue(presentationDefinition: PresentationDefinition)
  case fetchByReference(url: URL)
  case scopes(scopes: [String])
}

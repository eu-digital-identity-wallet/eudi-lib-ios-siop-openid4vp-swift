import Foundation

public enum PresentationDefinitionSource {
  case passByValue(presentationDefinition: PresentationDefinition)
  case fetchByReference(url: URL)
  case implied(scope: [String])
}

extension PresentationDefinitionSource {
  init(authorizationRequestData: AuthorizationRequestUnprocessedData) throws {
    if let presentationDefinitionString = authorizationRequestData.presentationDefinition {
      guard
        presentationDefinitionString.isValidJSONString
      else {
        throw ValidatedAuthorizationError.invalidPresentationDefinition
      }

      let parser = Parser()
      let result: Result<PresentationDefinitionContainer, ParserError> = parser.decode(
        json: presentationDefinitionString
      )
      guard
        let presentationDefinition = try? result.get().definition
      else {
        throw ValidatedAuthorizationError.invalidPresentationDefinition
      }
      self = .passByValue(presentationDefinition: presentationDefinition)
    } else if let presentationDefinitionUri = authorizationRequestData.presentationDefinitionUri,
              let uri = URL(string: presentationDefinitionUri),
              uri.scheme == "https" {
      self = .fetchByReference(url: uri)
    } else if let scopes = authorizationRequestData.scope?.components(separatedBy: " "),
              !scopes.isEmpty {
      self = .implied(scope: scopes)

    } else {

      throw ValidatedAuthorizationError.invalidPresentationDefinition
    }
  }
}

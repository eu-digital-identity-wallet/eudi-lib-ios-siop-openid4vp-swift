import Foundation

public struct Constants {
  public static let CLIENT_ID = "client_id"
  public static let NONCE = "nonce"
  public static let SCOPE = "scope"
  public static let STATE = "state"
  public static let PRESENTATION_DEFINITION = "presentation_definition"
  public static let PRESENTATION_DEFINITION_URI = "presentation_definition_uri"

  public static func presentationDefinitionPreview() -> PresentationDefinition {
    let parser = Parser()
    let result: Result<PresentationDefinitionContainer, ParserError> = parser.decode(
      path: "input_descriptors_example",
      type: "json"
    )

    let container = try? result.get()
    let definition = container?.definition

    return definition!
  }
}

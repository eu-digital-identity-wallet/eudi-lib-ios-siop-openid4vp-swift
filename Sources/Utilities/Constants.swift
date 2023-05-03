import Foundation
import logic_presentation_exchange

public struct Constants {
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

import Foundation

public protocol Resolving {
  associatedtype InputType
  associatedtype OutputType
  associatedtype ErrorType: Error
  func resolve(
    predefinedDefinitions: Dictionary<String, OutputType>,
    source: InputType
  ) -> Result<OutputType, ErrorType>
}

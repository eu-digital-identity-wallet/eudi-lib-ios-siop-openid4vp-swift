import Foundation

public protocol Resolving {
  associatedtype InputType
  associatedtype OutputType: Codable
  associatedtype ErrorType: Error
  func resolve(
    fetcher: Fetcher<OutputType>,
    predefinedDefinitions: Dictionary<String, OutputType>,
    source: InputType
  ) async -> Result<OutputType, ErrorType>
}

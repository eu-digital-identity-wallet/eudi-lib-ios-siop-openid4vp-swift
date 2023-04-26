import Foundation

public struct DescriptorMap: Codable {
  let id: String
  let format: String
  let path: String

  public init(id: String, format: String, path: String) {
    self.id = id
    self.format = format
    self.path = path
  }
}

import Foundation

public extension String {
  var base64urlEncode: String {
    let data = Data(self.utf8)
    let base64 = data.base64EncodedString()
    let base64url = base64
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
    return base64url
  }

  /// Loads the contents of a string file from the bundle associated with the Swift package.
  ///
  /// - Parameters:
  ///   - fileName: The name of the string file.
  ///   - fileExtension: The file extension of the string file.
  /// - Returns: The contents of the string file, or `nil` if it fails to load.
  static func loadStringFileFromBundle(named fileName: String, withExtension fileExtension: String) -> String? {
    let bundle = Bundle.module

    guard let fileURL = bundle.url(forResource: fileName, withExtension: fileExtension),
      let data = try? Data(contentsOf: fileURL),
      let string = String(data: data, encoding: .utf8) else {
      return nil
    }
    return string
  }
}

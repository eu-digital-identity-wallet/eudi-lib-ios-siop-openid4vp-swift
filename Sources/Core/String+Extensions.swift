import Foundation

public extension String {

  func isValidJWT() -> Bool {
      let jwtPattern = "^([A-Za-z0-9-_=]+)\\.([A-Za-z0-9-_=]+)\\.([A-Za-z0-9-_.+/=]*)$"
    guard let jwtRegex = try? NSRegularExpression(pattern: jwtPattern, options: []) else { return false }

      let matches = jwtRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf8.count))

      return matches.count == 1
  }

  func convertToDictionary() throws -> [String: Any]? {
    if let jsonData = self.data(using: .utf8) {
      let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
      return dictionary
    }
    return nil
  }

  // swiftlint:disable line_length
  var isValidJSONPath: Bool {
    guard
      let regex = try? NSRegularExpression(
        pattern: #"^\$((\.[\w-]+)|(\[[0-9]+\])|(\[\*\])|(\[\?\(@[\w-]+\s?(==|!=|<|<=|>|>=)\s?(['"])?[\w-]+(['"])?\)]))+$"#
      ) else {
      return false
    }
    let range = NSRange(location: 0, length: self.utf16.count)
    return regex.firstMatch(in: self, options: [], range: range) != nil
  }
  // swiftlint:enable line_length

  var isValidJSONString: Bool {
    guard let data = self.data(using: .utf8) else {
      return false
    }

    do {
      let json = try JSONSerialization.jsonObject(with: data, options: [])
      return json is [String: Any] || json is [Any]
    } catch {
      return false
    }
  }
}

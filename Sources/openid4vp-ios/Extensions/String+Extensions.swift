import Foundation

extension String {
  var isValidJSONPath: Bool {
    let regex = try! NSRegularExpression(pattern: #"^\$((\.[\w-]+)|(\[[0-9]+\])|(\[\*\])|(\[\?\(@[\w-]+\s?(==|!=|<|<=|>|>=)\s?(['"])?[\w-]+(['"])?\)]))+$"#)
    let range = NSRange(location: 0, length: self.utf16.count)
    return regex.firstMatch(in: self, options: [], range: range) != nil
  }
}
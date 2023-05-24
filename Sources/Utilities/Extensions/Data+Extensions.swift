import Foundation

extension Data {
  static func randomData(length: Int) -> Data {
    var data = Data(count: length)
    _ = data.withUnsafeMutableBytes { mutableBytes in
      if let bytes = mutableBytes.bindMemory(to: UInt8.self).baseAddress {
        return SecRandomCopyBytes(kSecRandomDefault, length, bytes)
      }
      fatalError("Failed to generate random bytes")
    }
    return data
  }

  func base64URLEncodedString() -> String {
    var base64String = self.base64EncodedString()
    base64String = base64String.replacingOccurrences(of: "/", with: "_")
    base64String = base64String.replacingOccurrences(of: "+", with: "-")
    base64String = base64String.replacingOccurrences(of: "=", with: "")
    return base64String
  }
}

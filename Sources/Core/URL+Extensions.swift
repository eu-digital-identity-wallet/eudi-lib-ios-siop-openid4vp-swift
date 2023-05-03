import Foundation

public extension URL {
  var queryParameters: [String: Any]? {
    guard
      let string = self.absoluteString.removingPercentEncoding,
      let components = URLComponents(string: string),
      let queryItems = components.queryItems else { return nil }
    return queryItems.reduce(into: [String: String]()) { (result, item) in
        result[item.name] = item.value
    }
  }
}

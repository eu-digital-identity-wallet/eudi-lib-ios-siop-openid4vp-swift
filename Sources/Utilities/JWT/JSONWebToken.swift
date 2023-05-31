import Foundation

public struct JSONWebToken {
  public let header: JSONWebTokenHeader
  public let payload: JSONObject
  public let signature: String

  /**
   Initializes a JSONWebToken instance with the provided components.

   - Parameters:
      - header: The header component of the JSON Web Token.
      - payload: The payload component of the JSON Web Token.
      - signature: The signature component of the JSON Web Token.
   */
  public init(header: JSONWebTokenHeader, payload: JSONObject, signature: String) {
    self.header = header
    self.payload = payload
    self.signature = signature
  }
}

public extension JSONWebToken {
  /**
   Initializes a JSONWebToken instance from a string representation of a JSON Web Token.

   - Parameters:
      - jsonWebToken: The string representation of the JSON Web Token.

   - Returns: A new JSONWebToken instance, or `nil` if the initialization fails.
   */
  init?(jsonWebToken: String) {
    let encodedData = { (string: String) -> Data? in
      var encodedString = string.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")

      switch encodedString.utf16.count % 4 {
      case 2: encodedString = "\(encodedString)=="
      case 3: encodedString = "\(encodedString)="
      default: break
      }
      return Data(base64Encoded: encodedString)
    }

    let components = jsonWebToken.components(separatedBy: ".")

    guard
      components.count == 3,
      let headerData = encodedData(components[0] as String),
      let payloadData = encodedData(components[1] as String)
    else {
      return nil
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    do {
      header = try decoder.decode(JSONWebTokenHeader.self, from: headerData)
      payload = try JSONSerialization.jsonObject(with: payloadData, options: .allowFragments) as? JSONObject ?? [:]
      signature = components[2] as String
    } catch {
      return nil
    }
  }
}

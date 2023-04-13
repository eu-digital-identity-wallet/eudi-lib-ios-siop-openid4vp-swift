import Foundation

public enum ResponseMode {
  case directPost(responseURI: URL)
  case none
}

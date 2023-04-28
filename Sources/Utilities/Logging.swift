import Foundation
import os

extension Logger: Injectable {
  private static var subsystem = Bundle.main.bundleIdentifier
  static let lifecycle = Logger(subsystem: subsystem ?? "sdk", category: "lifecycle")
}

class Reporter: Injectable {
  private let logger = Logger()

  func debug(_ message: String) {
    Logger.lifecycle.debug("\(message)")
  }

  func info(_ message: String) {
    Logger.lifecycle.debug("\(message)")
  }
}

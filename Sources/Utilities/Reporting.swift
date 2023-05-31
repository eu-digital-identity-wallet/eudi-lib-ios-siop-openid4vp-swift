import Foundation
import os

extension Logger {
  private static var subsystem = Bundle.main.bundleIdentifier
  static let lifecycle = Logger(subsystem: subsystem ?? "sdk", category: "lifecycle")
}

public protocol Reporting {
  func debug(_ message: String)
  func info(_ message: String)
}

class Reporter: Reporting {
  private let logger = Logger()

  func debug(_ message: String) {
    Logger.lifecycle.debug("\(message)")
  }

  func info(_ message: String) {
    Logger.lifecycle.info("\(message)")
  }
}

class MockReporter: Reporting {
  private let logger = Logger()

  func debug(_ message: String) {
    Logger.lifecycle.debug("Mock: \(message)")
  }

  func info(_ message: String) {
    Logger.lifecycle.debug("Mock: \(message)")
  }
}

import Foundation

protocol Injectable {}

final class DependencyStore {
  static let shared = DependencyStore()
  private var store: [String: Dependency<Any>] = [:]

  func register<T: Injectable, U>(_ initializer: @escaping @autoclosure () -> T, for type: U.Type) {
    let key = identifier(for: U.self)
    if store.keys.contains(key) {
      fatalError("Attempted to register \(key) twice.")
    }
    store[key] = Dependency(initializer: initializer)
  }

  func resolve<T>() -> T {
    let key = identifier(for: T.self)

    guard let dependency = store[key] else {
      fatalError("Could not resolve for \(T.self)")
    }

    if let value = dependency.value as? T {
      return value

    } else if let value = dependency.initializer() as? T {
      store[key]?.value = value
      return value

    } else {
      // Never happens due to the register function being generic - this is needed only because `store.value` is `Any`

      fatalError("Could not cast \(String(describing: dependency.initializer)) to \(T.self)")
    }
  }

  private func identifier<T>(for protocol: T) -> String {
    String(describing: T.self)
  }
}

private extension DependencyStore {
  struct Dependency<T> {
    let initializer: () -> Any
    var value: T?
  }
}

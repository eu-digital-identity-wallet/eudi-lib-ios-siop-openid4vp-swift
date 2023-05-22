import Foundation

@propertyWrapper
public struct Injected<T> {
  private(set) public var wrappedValue: T
  public init(
    container: DIContainer = DependencyContainer.shared,
    key: String? = nil,
    mode: ResolveMode = .shared
  ) {
    if let key = key {
      wrappedValue = DependencyContainer.shared.resolve(key: key, mode: mode)
    } else {
      wrappedValue = DependencyContainer.shared.resolve(type: T.self, mode: mode)
    }
  }
}

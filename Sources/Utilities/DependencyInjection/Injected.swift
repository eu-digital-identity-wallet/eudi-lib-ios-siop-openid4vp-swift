import Foundation

@propertyWrapper
class Injected<T> {
  var wrappedValue: T {
    let object: T = DependencyStore.shared.resolve()
    return object
  }
}

import Foundation

extension Sequence {
  func associate<K, V>(transform: (Element) -> (K, V)) -> [K: V] {
    return reduce(into: [K: V]()) { result, element in
      let (key, value) = transform(element)
      result[key] = value
    }
  }

  func associateWith<T>(_ transform: (Element) -> T) -> [Element: T] {
    let pairs = map { element in
      (element, transform(element))
    }
    return Dictionary(uniqueKeysWithValues: pairs)
  }
}

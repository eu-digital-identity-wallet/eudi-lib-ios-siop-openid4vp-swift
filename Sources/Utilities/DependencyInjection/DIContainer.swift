import Foundation

public protocol DIContainer {
  func register<DependencyType, DependencyInstance>(
    type: DependencyType.Type,
    dependency: @escaping () -> DependencyInstance
  )
  func register<DependencyType>(key: String, dependency: @escaping () -> DependencyType)
  func resolve<DependencyType>(type: DependencyType.Type, mode: ResolveMode) -> DependencyType
  func resolve<DependencyType>(key: String, mode: ResolveMode) -> DependencyType

  func remove<DependencyType>(type: DependencyType.Type)
  func remove(key: String)
  func removeAll()
}

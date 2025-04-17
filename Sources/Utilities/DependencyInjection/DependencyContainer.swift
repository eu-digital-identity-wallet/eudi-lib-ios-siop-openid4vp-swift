/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import Foundation

public final class DependencyContainer: DIContainer {

  // MARK: - Properties

  public static let shared: DIContainer = DependencyContainer()
  nonisolated(unsafe) private var dependencyInitializer: [String: () -> Any] = [:]
  nonisolated(unsafe) private var dependencyShared: [String: Any] = [:]

  public func register<DependencyType, DependencyInstance>(
    type: DependencyType.Type,
    dependency: @escaping () -> DependencyInstance
  ) {
    register(key: dependencyKey(for: type), dependency: dependency)
  }

  public func register<DependencyType>(key: String, dependency: @escaping () -> DependencyType) {
    dependencyInitializer[key] = dependency
  }

  public func resolve<DependencyType>(type: DependencyType.Type, mode: ResolveMode) -> DependencyType {
    return resolve(key: dependencyKey(for: type), mode: mode)
  }

  public func resolve<DependencyType>(key: String, mode: ResolveMode) -> DependencyType {
    switch mode {
    case .new:
      guard let newDependency = dependencyInitializer[key]?() as? DependencyType else {
        preconditionFailure("There is no dependency registered for this type.")
      }
      return newDependency
    case .shared:
      if dependencyShared[key] == nil, let dependency = dependencyInitializer[key]?() {
        dependencyShared[key] = dependency
      }

      guard let sharedDependency = dependencyShared[key] as? DependencyType else {
        preconditionFailure("There is no dependency registered for this type.")
      }
      return sharedDependency
    }
  }

  private func dependencyKey<DependencyType>(for type: DependencyType.Type) -> String {
    String(describing: type)
  }
}

extension DependencyContainer {

  // MARK: - Remove

  public func remove<DependencyType>(type: DependencyType.Type) {
    remove(key: dependencyKey(for: type))
  }

  public func remove(key: String) {
    dependencyInitializer.removeValue(forKey: key)
    dependencyShared.removeValue(forKey: key)
  }

  public func removeAll() {
    dependencyInitializer = [:]
    dependencyShared = [:]
  }
}

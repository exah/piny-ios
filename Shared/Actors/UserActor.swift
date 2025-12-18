import SwiftData
import SwiftUI

@ModelActor
actor UserActor {
  func fetch() throws -> [User] {
    try modelContext.fetch(FetchDescriptor<User>())
  }

  func find() -> User? {
    try? fetch().last
  }

  func get() throws -> User {
    guard let user = find() else {
      throw Piny.Error.runtimeError("User not found")
    }

    return user
  }

  func insert(_ user: User) {
    modelContext.insert(user)
  }

  func delete(_ user: User) {
    modelContext.delete(user)
  }

  func reset() throws {
    try modelContext.delete(model: User.self, includeSubclasses: true)
  }
}

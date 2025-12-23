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

  func insert(_ user: User) throws {
    modelContext.insert(user)
    try modelContext.save()
  }

  func delete(_ user: User) throws {
    modelContext.delete(user)
    try modelContext.save()
  }

  func clear() throws {
    try modelContext.delete(model: User.self)
  }
}

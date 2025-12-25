import SwiftData
import SwiftUI

@ModelActor
actor UserActor {
  func fetch() throws -> [UserModel] {
    try modelContext.fetch(FetchDescriptor<UserModel>())
  }

  func find() -> UserModel? {
    try? fetch().last
  }

  func get() throws -> UserModel {
    guard let user = find() else {
      throw Piny.Error.runtimeError("User not found")
    }

    return user
  }

  func insert(_ user: UserModel) throws {
    modelContext.insert(user)
    try modelContext.save()
  }

  func delete(_ user: UserModel) throws {
    modelContext.delete(user)
    try modelContext.save()
  }

  func clear() throws {
    try modelContext.delete(model: UserModel.self)
    try modelContext.save()
  }
}

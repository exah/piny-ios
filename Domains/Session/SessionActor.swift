import SwiftData
import SwiftUI

@ModelActor
actor SessionActor {
  func fetch() throws -> [SessionModel] {
    try modelContext.fetch(FetchDescriptor<SessionModel>())
  }

  func find() -> SessionModel? {
    try? fetch().last
  }

  func get() throws -> SessionModel {
    guard let session = find() else {
      throw Piny.Error.runtimeError("Session not found")
    }

    return session
  }

  func insert(_ session: SessionModel) throws {
    modelContext.insert(session)
    try modelContext.save()
  }

  func delete(_ session: SessionModel) throws {
    modelContext.delete(session)
    try modelContext.save()
  }

  func clear() throws {
    try modelContext.delete(model: SessionModel.self)
    try modelContext.save()
  }
}

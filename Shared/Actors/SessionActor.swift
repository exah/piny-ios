import SwiftData
import SwiftUI

@ModelActor
actor SessionActor {
  func fetch() throws -> [Session] {
    try modelContext.fetch(FetchDescriptor<Session>())
  }

  func find() -> Session? {
    try? fetch().last
  }

  func get() throws -> Session {
    guard let session = find() else {
      throw Piny.Error.runtimeError("Session not found")
    }

    return session
  }

  func insert(_ session: Session) throws {
    modelContext.insert(session)
    try modelContext.save()
  }

  func delete(_ session: Session) throws {
    modelContext.delete(session)
    try modelContext.save()
  }

  func clear() throws {
    try modelContext.delete(model: Session.self)
    try modelContext.save()
  }
}

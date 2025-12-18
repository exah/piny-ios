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

  func insert(_ session: Session) {
    modelContext.insert(session)
  }

  func delete(_ session: Session) {
    modelContext.delete(session)
  }

  func sync(session: Session) throws {
    try modelContext.transaction {
      try modelContext.delete(model: Session.self)
      modelContext.insert(session)
    }
  }

  func sync(session: Session, user: User) throws {
    try modelContext.transaction {
      try modelContext.delete(model: Session.self)
      try modelContext.delete(model: User.self)

      modelContext.insert(session)
      modelContext.insert(user)
    }
  }

  func reset() throws {
    try modelContext.delete(model: Session.self, includeSubclasses: true)
  }
}

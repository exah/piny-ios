import SwiftData
import SwiftUI

@ModelActor
actor SessionActor {
  enum Descriptors {
    typealias Fetch = FetchDescriptor<SessionModel>
    typealias Sort = SortDescriptor<SessionModel>

    static func sort(_ order: SortOrder = .reverse) -> Sort {
      SortDescriptor(\.expiresAt, order: order)
    }

    static func all() -> Fetch {
      FetchDescriptor()
    }

    static func last() -> Fetch {
      var descriptor: Fetch = FetchDescriptor(sortBy: [sort()])
      descriptor.fetchLimit = 1
      return descriptor
    }
  }

  func fetch() throws -> [SessionModel] {
    try modelContext.fetch(Descriptors.all())
  }

  func find() -> SessionModel? {
    try? modelContext.fetch(Descriptors.last()).first
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

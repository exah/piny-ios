import Foundation
import SwiftData

@ModelActor
actor TagActor {
  enum Descriptors {
    typealias Fetch = FetchDescriptor<TagModel>
    typealias Sort = SortDescriptor<TagModel>

    static func sort(_ order: SortOrder = .forward) -> Sort {
      SortDescriptor(\.name, order: order)
    }

    static func all() -> Fetch {
      FetchDescriptor(
        sortBy: [sort()]
      )
    }

    static func find(by names: [String]) throws -> Fetch {
      FetchDescriptor(
        predicate: #Predicate { tag in
          names.contains(tag.name)
        },
        sortBy: [sort()]
      )
    }
  }

  func fetch() throws -> [TagModel] {
    try modelContext.fetch(Descriptors.all())
  }

  func get(by name: String) throws -> TagModel {
    guard let pin = try? find(by: name) else {
      throw Piny.Error.runtimeError("TagModel not found by name: \(name)")
    }

    return pin
  }

  func find(by name: String) throws -> TagModel? {
    try find(by: [name]).first
  }

  func find(by names: [String]) throws -> [TagModel] {
    try modelContext.fetch(Descriptors.find(by: names))
  }

  @discardableResult
  func insert(_ name: String, id: UUID = UUID()) throws -> TagModel {
    if let existing = try? find(by: name) {
      return existing
    }

    let tag = TagModel(id: id, name: name)
    modelContext.insert(tag)
    try modelContext.save()

    return tag
  }

  func insert(tags: [TagModel]) throws {
    let existing = Set(try find(by: tags.map { $0.name }).map { $0.name })

    try modelContext.transaction {
      for tag in tags {
        if existing.contains(tag.name) {
          continue
        }

        modelContext.insert(tag)
      }
    }
  }

  func deleteOrphaned() throws {
    let tags = try fetch()
    let orphaned = Set(tags.filter { $0.pins?.isEmpty ?? true }.map { $0.name })

    if orphaned.isEmpty {
      return
    }

    try modelContext.transaction {
      try modelContext.delete(
        model: TagModel.self,
        where: #Predicate { orphaned.contains($0.name) }
      )
    }
  }

  func clear() throws {
    try modelContext.delete(model: TagModel.self)
    try modelContext.save()
  }
}

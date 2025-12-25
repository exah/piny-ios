import SwiftData
import SwiftUI

@ModelActor
actor TagActor {
  func fetch() throws -> [TagModel] {
    try modelContext.fetch(FetchDescriptor<TagModel>())
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
    try modelContext.fetch(
      FetchDescriptor<TagModel>(
        predicate: #Predicate { tag in
          names.contains(tag.name)
        }
      )
    )
  }

  @discardableResult
  func insert(_ name: String, id: UUID = UUID()) throws -> TagModel {
    let tag: TagModel
    if let existing = try? find(by: name) {
      tag = existing
    } else {
      tag = TagModel(id: id, name: name)
      modelContext.insert(tag)
      try modelContext.save()
    }

    return tag
  }

  func insert(tags: [TagModel]) throws {
    tags.forEach { modelContext.insert($0) }
    try modelContext.save()
  }

  func clear() throws {
    try modelContext.delete(model: TagModel.self)
    try modelContext.save()
  }
}

import SwiftData
import SwiftUI

@ModelActor
actor TagsActor {
  func fetch() throws -> [PinTag] {
    try modelContext.fetch(FetchDescriptor<PinTag>())
  }

  func get(by name: String) throws -> PinTag {
    guard let pin = try? find(by: name) else {
      throw Piny.Error.runtimeError("PinTag not found by name: \(name)")
    }

    return pin
  }

  func find(by name: String) throws -> PinTag? {
    try find(by: [name]).first
  }

  func find(by names: [String]) throws -> [PinTag] {
    try modelContext.fetch(
      FetchDescriptor<PinTag>(
        predicate: #Predicate { tag in
          names.contains(tag.name)
        }
      )
    )
  }

  func insert(_ name: String, id: UUID = UUID()) throws {
    let tag: PinTag
    if let existing = try? find(by: name) {
      tag = existing
    } else {
      tag = PinTag(id: id, name: name)
      modelContext.insert(tag)
      try modelContext.save()
    }
  }

  func insert(tags: [PinTag]) throws {
    tags.forEach { modelContext.insert($0) }
    try modelContext.save()
  }

  func clear() throws {
    try modelContext.delete(model: PinTag.self)
  }
}

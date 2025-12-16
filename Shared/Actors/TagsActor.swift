import SwiftData
import SwiftUI

@ModelActor
public actor TagsActor {
  func fetch() throws -> [PinTag] {
    try modelContext.fetch(FetchDescriptor<PinTag>())
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

  @discardableResult
  func create(_ name: String, id: UUID = UUID()) throws -> PinTag {
    let tag: PinTag
    if let existing = try? find(by: name) {
      tag = existing
    } else {
      tag = PinTag(id: id, name: name)
      modelContext.insert(tag)
    }

    return tag
  }

  func insert(tags: [PinTag]) {
    tags.forEach { modelContext.insert($0) }
  }
}

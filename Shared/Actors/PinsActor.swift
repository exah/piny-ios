import SwiftData
import SwiftUI

@ModelActor
actor PinsActor {
  let tagsActor = TagsActor(modelContainer: .shared)

  func fetch() throws -> [Pin] {
    try modelContext.fetch(FetchDescriptor<Pin>())
  }

  func get(by id: UUID) throws -> Pin {
    guard let pin = try? find(by: id) else {
      throw Piny.Error.runtimeError("Pin not found by id: \(id)")
    }

    return pin
  }

  func find(by id: UUID) throws -> Pin? {
    try find(by: [id]).first
  }

  func find(by ids: [UUID]) throws -> [Pin] {
    try modelContext.fetch(
      FetchDescriptor<Pin>(
        predicate: #Predicate { pin in
          ids.contains(pin.id)
        }
      )
    )
  }

  func insert(_ pin: Pin) {
    modelContext.insert(pin)
  }

  func insert(pins: [Pin]) {
    pins.forEach { insert($0) }
  }

  func delete(_ pin: Pin) {
    modelContext.delete(pin)
  }

  func sync(_ serverPins: [PinDTO]) async throws {
    let storagePins = try fetch()
    let storageTags = try await tagsActor.fetch()

    try modelContext.transaction {
      let serverPinIds = Set(serverPins.map { $0.id })

      storagePins
        .filter { !serverPinIds.contains($0.id) }
        .forEach { modelContext.delete($0) }

      for item in serverPins {
        if let pin = storagePins.first(where: { $0.id == item.id }) {
          pin.update(from: item, tags: storageTags)
        } else {
          let pin = Pin(from: item, tags: storageTags)
          self.modelContext.insert(pin)
        }
      }
    }
  }

  func reset() throws {
    try modelContext.delete(model: Pin.self, includeSubclasses: true)
  }
}

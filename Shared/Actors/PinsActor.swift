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

  func insert(_ pin: Pin) throws {
    modelContext.insert(pin)
    try modelContext.save()
  }

  func insert(pins: [Pin]) throws {
    pins.forEach { modelContext.insert($0) }
    try modelContext.save()
  }

  func delete(_ pin: Pin) throws {
    modelContext.delete(pin)
    try modelContext.save()
  }

  func sync(_ serverPins: [PinDTO]) async throws {
    let storagePins = try fetch()
    let storageTags = try await tagsActor.fetch()
    let serverPinIds = Set(serverPins.map { $0.id })

    storagePins
      .filter { !serverPinIds.contains($0.id) }
      .forEach { modelContext.delete($0) }

    for item in serverPins {
      if let pin = storagePins.first(where: { $0.id == item.id }) {
        pin.update(from: item, tags: storageTags)
      } else {
        let pin = Pin(from: item, tags: storageTags)
        modelContext.insert(pin)
      }
    }

    try modelContext.save()
  }

  func clear() throws {
    try modelContext.delete(model: Pin.self)
  }
}

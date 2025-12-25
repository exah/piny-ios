import SwiftData
import SwiftUI

@ModelActor
actor PinActor {
  let tagActor = TagActor(modelContainer: .shared)

  func fetch() throws -> [PinModel] {
    try modelContext.fetch(FetchDescriptor<PinModel>())
  }

  func get(by id: UUID) throws -> PinModel {
    guard let pin = try? find(by: id) else {
      throw Piny.Error.runtimeError("PinModel not found by id: \(id)")
    }

    return pin
  }

  func find(by id: UUID) throws -> PinModel? {
    try find(by: [id]).first
  }

  func find(by ids: [UUID]) throws -> [PinModel] {
    try modelContext.fetch(
      FetchDescriptor<PinModel>(
        predicate: #Predicate { pin in
          ids.contains(pin.id)
        }
      )
    )
  }

  func insert(_ pin: PinModel) throws {
    modelContext.insert(pin)
    try modelContext.save()
  }

  func insert(pins: [PinModel]) throws {
    pins.forEach { modelContext.insert($0) }
    try modelContext.save()
  }

  func delete(_ pin: PinModel) throws {
    modelContext.delete(pin)
    try modelContext.save()
  }

  func sync(_ serverPins: [PinDTO]) async throws {
    let storagePins = try fetch()
    let storageTags = try await tagActor.fetch()
    let serverPinIds = Set(serverPins.map { $0.id })

    storagePins
      .filter { !serverPinIds.contains($0.id) }
      .forEach { modelContext.delete($0) }

    for item in serverPins {
      if let pin = storagePins.first(where: { $0.id == item.id }) {
        pin.update(from: item, tags: storageTags)
      } else {
        let pin = PinModel(from: item, tags: storageTags)
        modelContext.insert(pin)
      }
    }

    try modelContext.save()
  }

  func clear() throws {
    try modelContext.delete(model: PinModel.self)
    try modelContext.save()
  }
}

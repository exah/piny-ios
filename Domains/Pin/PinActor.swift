import Foundation
import SwiftData

@ModelActor
actor PinActor {
  lazy var tagActor = TagActor(modelContainer: modelContainer)
  lazy var linkActor = LinkActor(modelContainer: modelContainer)

  enum Descriptors {
    typealias Fetch = FetchDescriptor<PinModel>
    typealias Sort = SortDescriptor<PinModel>

    static func sort(_ order: SortOrder = .reverse) -> Sort {
      SortDescriptor(\.createdAt, order: order)
    }

    static func all() -> Fetch {
      FetchDescriptor(
        sortBy: [sort()]
      )
    }

    static func find(by ids: [UUID]) throws -> Fetch {
      FetchDescriptor(
        predicate: #Predicate { ids.contains($0.id) },
        sortBy: [sort()]
      )
    }
  }

  func fetch() throws -> [PinModel] {
    try modelContext.fetch(Descriptors.all())
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
    try modelContext.fetch(Descriptors.find(by: ids))
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
    let storageLinks = try await linkActor.fetch()
    let serverPinIds = Set(serverPins.map { $0.id })

    let storagePinsById = PinModel.group(storagePins)
    let storageLinksByURL = LinkModel.group(storageLinks)
    let storageTagsByName = TagModel.group(storageTags)

    try modelContext.transaction {
      storagePins
        .filter { !serverPinIds.contains($0.id) }
        .forEach { modelContext.delete($0) }

      for item in serverPins {
        if let pin = storagePinsById[item.id] {
          pin.update(
            from: item,
            link: LinkModel.resolve(with: item.link, links: storageLinksByURL),
            tags: TagModel.resolve(with: item.tags, tags: storageTagsByName)
          )
        } else {
          modelContext.insert(
            PinModel(
              from: item,
              link: LinkModel.resolve(with: item.link, links: storageLinksByURL),
              tags: TagModel.resolve(with: item.tags, tags: storageTagsByName)
            )
          )
        }
      }
    }

    try await linkActor.deleteOrphaned()
    try await tagActor.deleteOrphaned()
  }

  func clear() throws {
    try modelContext.delete(model: PinModel.self)
    try modelContext.save()
  }
}

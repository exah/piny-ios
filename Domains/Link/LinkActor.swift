import Foundation
import SwiftData

@ModelActor
actor LinkActor {
  lazy var pinActor = PinActor(modelContainer: modelContainer)

  enum Descriptors {
    typealias Fetch = FetchDescriptor<LinkModel>

    static func all() -> Fetch {
      FetchDescriptor()
    }

    static func find(by url: URL) -> Fetch {
      FetchDescriptor(
        predicate: #Predicate { link in
          link.url == url
        },
      )
    }
  }

  func fetch() throws -> [LinkModel] {
    try modelContext.fetch(Descriptors.all())
  }

  func find(by url: URL) -> LinkModel? {
    var descriptor = Descriptors.find(by: url)
    descriptor.fetchLimit = 1

    return try? modelContext.fetch(descriptor).first
  }

  func insert(_ dto: LinkDTO) throws -> LinkModel {
    if let existing = find(by: dto.url) {
      return existing
    }

    let link = LinkModel(from: dto)
    modelContext.insert(link)
    try modelContext.save()

    return link
  }

  func deleteOrphaned() async throws {
    let links = try fetch().map { $0.url }
    let pins = try await pinActor.fetch()
    let existing = Set(pins.map { $0.link.url })
    let orphaned = Set(links.filter { !existing.contains($0) })

    if orphaned.isEmpty {
      return
    }

    try modelContext.transaction {
      try modelContext.delete(
        model: LinkModel.self,
        where: #Predicate { orphaned.contains($0.url) }
      )
    }
  }
}

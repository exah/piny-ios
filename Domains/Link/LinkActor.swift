import Foundation
import SwiftData

@ModelActor
actor LinkActor {
  enum Descriptors {
    typealias Model = FetchDescriptor<LinkModel>

    static func fetch() -> Model {
      FetchDescriptor()
    }

    static func find(by url: URL) -> Model {
      FetchDescriptor(
        predicate: #Predicate { link in
          link.url == url
        },
      )
    }
  }

  func fetch() throws -> [LinkModel] {
    try modelContext.fetch(Descriptors.fetch())
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
}

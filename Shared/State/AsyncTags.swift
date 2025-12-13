//
//  TagsState.swift
//  piny
//
//  Created by J. Grishin on 23/08/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import Combine
import Foundation
import SwiftData
import SwiftUI

struct AsyncTagsResult {
  let fetch = AsyncResult<[PinTag]>()
}

@Observable
class AsyncTags: Async {
  let result = AsyncTagsResult()

  @MainActor
  init(_ initial: [PinTag] = [], modelContext: ModelContext? = nil) {
    super.init(modelContext: modelContext)
    initial.forEach { self.modelContext.insert($0) }
  }

  @MainActor
  @discardableResult
  func fetch() async throws -> [PinTag] {
    try await result.fetch.capture {
      let tagsDTO = try await Piny.api.get(
        [PinTagDTO].self,
        path: "/tags"
      )

      let existing =
        (try? self.modelContext.fetch(FetchDescriptor<PinTag>())) ?? []
      let newTags =
        tagsDTO
        .filter { tag in !existing.contains(where: { $0.id == tag.id }) }
        .map { PinTag(from: $0) }

      newTags.forEach { self.modelContext.insert($0) }

      return newTags
    }
  }
}

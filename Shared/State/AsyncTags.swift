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
  let tagsActor = TagsActor(modelContainer: .shared)

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

      let existing = try await tagsActor.fetch()
      let newTags =
        tagsDTO
        .filter { tag in !existing.contains(where: { $0.name == tag.name }) }
        .map { PinTag(from: $0) }

      await withThrowingTaskGroup(of: Void.self) { group in
        for tag in newTags {
          group.addTask {
            try await self.tagsActor.create(tag.name)
          }
        }
      }

      return try await tagsActor.fetch()
    }
  }
}

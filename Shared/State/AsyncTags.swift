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
class AsyncTags {
  let result = AsyncTagsResult()
  let tagsActor = TagsActor(modelContainer: .shared)

  @MainActor
  init(_ initial: [PinTag] = []) {
    Task {
      await tagsActor.insert(tags: initial)
      result.fetch.status = .success(initial)
    }
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
            try await self.tagsActor.create(tag.name, id: tag.id)
          }
        }
      }

      return try await tagsActor.fetch()
    }
  }
}

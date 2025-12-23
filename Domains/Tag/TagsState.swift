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

struct AsyncTags {
  let fetch = Async<[PinTag]>()
}

@Observable
class TagsState {
  let result = AsyncTags()
  let tagsActor = TagsActor(modelContainer: .shared)

  init(_ initial: [PinTag] = []) {
    Task {
      try await tagsActor.insert(tags: initial)
      result.fetch.status = .success(initial)
    }
  }

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
            try await self.tagsActor.insert(tag.name, id: tag.id)
          }
        }
      }

      return try await tagsActor.fetch()
    }
  }
}

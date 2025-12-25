//
//  TagState.swift
//  piny
//
//  Created by J. Grishin on 23/08/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import Combine
import Foundation
import SwiftData
import SwiftUI

struct AsyncTagResult {
  let fetch = Async<[TagModel]>()
}

@Observable
class TagState {
  let result = AsyncTagResult()
  let tagActor = TagActor(modelContainer: .shared)

  init(_ initial: [TagModel] = []) {
    Task {
      try await tagActor.insert(tags: initial)
      result.fetch.status = .success(initial)
    }
  }

  @discardableResult
  func fetch() async throws -> [TagModel] {
    try await result.fetch.capture {
      let tagsDTO = try await Piny.api.get(
        [PinTagDTO].self,
        path: "/tags"
      )

      let existing = try await tagActor.fetch()
      let newTags =
        tagsDTO
        .filter { tag in !existing.contains(where: { $0.name == tag.name }) }
        .map { TagModel(from: $0) }

      await withThrowingTaskGroup(of: Void.self) { group in
        for tag in newTags {
          group.addTask {
            try await self.tagActor.insert(tag.name, id: tag.id)
          }
        }
      }

      return try await tagActor.fetch()
    }
  }
}

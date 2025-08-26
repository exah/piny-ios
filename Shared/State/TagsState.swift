//
//  TagsState.swift
//  piny
//
//  Created by J. Grishin on 23/08/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//


import Foundation
import PromiseKit
import Combine

final class TagsState: AsyncState {
  @Published var tags: [PinTag] = []
  @Published var isLoading: Bool = false

  init(_ initial: [PinTag]? = nil) {
    if let tags = initial {
      self.tags = tags
    } else {
      let sort = NSSortDescriptor(key: "name", ascending: false)
      let tags = Piny.storage.fetch(PinTag.self, sortDescriptors: [sort])

      if tags.count > 0 {
        self.tags = tags
      }

      Piny.log("Fetched from store tags: \(tags.count)")
    }
  }

  func fetch() -> Promise<[PinTag]> {
    capture {
      Piny.api.get(
        [PinTag].self,
        path: "/tags"
      ).get { tags in
        self.tags = tags

        Piny.storage.remove(PinTag.self)
        Piny.storage.save(tags)
      }
    }
  }
}

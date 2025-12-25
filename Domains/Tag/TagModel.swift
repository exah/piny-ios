//
//  TagModel.swift
//  piny
//
//  Created by John Grishin on 21/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import SwiftData

@Model
class TagModel: Identifiable, Equatable, Hashable {
  @Attribute(.unique)
  var id: UUID
  @Attribute(.unique)
  var name: String
  var pins: [PinModel]? = []

  init(id: UUID, name: String) {
    self.id = id
    self.name = name
  }

  convenience init(from tag: TagDTO) {
    self.init(
      id: tag.id,
      name: tag.name
    )
  }

  static func == (lhs: TagModel, rhs: TagModel) -> Bool {
    return lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension PreviewContent {
  static let tags: [TagModel] = tagsDTO.map { TagModel(from: $0) }
}

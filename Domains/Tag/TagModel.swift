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

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: TagModel, rhs: TagModel) -> Bool {
    return lhs.id == rhs.id
  }

  typealias Group = [String: TagModel]
  static func group(_ tags: [TagModel]) -> Group {
    Dictionary(uniqueKeysWithValues: tags.map { ($0.name, $0) })
  }

  static func resolve(with dto: TagDTO, tags: Group) -> TagModel {
    tags[dto.name] ?? TagModel(from: dto)
  }

  static func resolve(with dto: [TagDTO], tags: Group) -> [TagModel] {
    dto.map { resolve(with: $0, tags: tags) }
  }
}

extension PreviewContent {
  static let tags: [TagModel] = tagsDTO.map { TagModel(from: $0) }
  static let groupedTags = TagModel.group(tags)
}

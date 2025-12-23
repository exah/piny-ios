//
//  PinTag.swift
//  piny
//
//  Created by John Grishin on 21/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import SwiftData

@Model
class PinTag: Identifiable, Equatable, Hashable {
  @Attribute(.unique)
  var id: UUID
  @Attribute(.unique)
  var name: String
  var pins: [Pin]? = []

  init(id: UUID, name: String) {
    self.id = id
    self.name = name
  }

  convenience init(from tag: PinTagDTO) {
    self.init(
      id: tag.id,
      name: tag.name
    )
  }

  static func == (lhs: PinTag, rhs: PinTag) -> Bool {
    return lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

struct PinTagDTO: Hashable, Equatable, Codable, Identifiable {
  var id: UUID
  var name: String
}

extension PreviewContent {
  static let tagsDTO: [PinTagDTO] = load("preview-tags.json")
  static let tags: [PinTag] = tagsDTO.map { PinTag(from: $0) }
}

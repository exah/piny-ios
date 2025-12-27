//
//  PinModel.swift
//  piny
//
//  Created by John Grishin on 15/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import SwiftData

@Model
class PinModel: Identifiable, Equatable {
  @Attribute(.unique)
  var id: UUID
  var title: String = ""
  var desc: String = ""
  var privacy: PinPrivacy
  @Relationship(deleteRule: .cascade)
  var link: LinkModel
  @Relationship(inverse: \TagModel.pins)
  var tags: [TagModel] = []
  var createdAt: Date
  var updatedAt: Date

  init(
    id: UUID,
    title: String,
    desc: String,
    privacy: PinPrivacy,
    link: LinkModel,
    tags: [TagModel],
    createdAt: Date,
    updatedAt: Date
  ) {
    self.id = id
    self.title = title
    self.desc = desc
    self.privacy = privacy
    self.link = link
    self.tags = tags
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  convenience init(
    from pin: PinDTO,
    link: LinkModel,
    tags: [TagModel]
  ) {
    self.init(
      id: pin.id,
      title: pin.title,
      desc: pin.description,
      privacy: pin.privacy,
      link: link,
      tags: tags,
      createdAt: pin.createdAt,
      updatedAt: pin.updatedAt
    )
  }

  func update(
    from pin: PinDTO,
    link: LinkModel,
    tags: [TagModel]
  ) {
    self.title = pin.title
    self.desc = pin.description
    self.privacy = pin.privacy
    self.link = link
    self.tags = tags
    self.updatedAt = pin.updatedAt
  }

  typealias Group = [UUID: PinModel]
  static func group(_ pins: [PinModel]) -> Group {
    Dictionary(uniqueKeysWithValues: pins.map { ($0.id, $0) })
  }

  static func == (lhs: PinModel, rhs: PinModel) -> Bool {
    return lhs.id == rhs.id
  }
}

extension PreviewContent {
  static let pins: [PinModel] = pinsDTO.map {
    PinModel(
      from: $0,
      link: LinkModel(from: $0.link),
      tags: TagModel.resolve(with: $0.tags, tags: groupedTags)
    )
  }
}

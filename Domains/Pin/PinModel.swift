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

  convenience init(from pin: PinDTO, tags: [TagModel]) {
    self.init(
      id: pin.id,
      title: pin.title,
      desc: pin.description,
      privacy: pin.privacy,
      link: LinkModel(from: pin.link),
      tags: pin.tags
        .map { tag in
          tags.first(where: { $0.name == tag.name }) ?? TagModel(from: tag)
        },
      createdAt: pin.createdAt,
      updatedAt: pin.updatedAt
    )
  }

  func update(from pin: PinDTO, tags: [TagModel]) {
    self.title = pin.title
    self.desc = pin.description
    self.privacy = pin.privacy
    self.link.url = pin.link.url
    self.tags = pin.tags
      .map { tag in
        tags.first(where: { $0.name == tag.name }) ?? TagModel(from: tag)
      }
    self.updatedAt = pin.updatedAt
  }

  static func == (lhs: PinModel, rhs: PinModel) -> Bool {
    return lhs.id == rhs.id
  }
}

struct PinDTO: Hashable, Codable, Identifiable, Equatable {
  var id: UUID
  var title: String
  var description: String
  var privacy: PinPrivacy
  var link: LinkDTO
  var tags: [PinTagDTO]
  var createdAt: Date
  var updatedAt: Date

  struct Payload: Codable {
    var url: URL
    var title: String
    var description: String
    var privacy: PinPrivacy
    var tags: [String]
  }
}

extension PreviewContent {
  static let pinsDTO: [PinDTO] = load("preview-pins.json")
  static let pins: [PinModel] = pinsDTO.map { PinModel(from: $0, tags: tags) }
}

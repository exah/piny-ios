//
//  Pin.swift
//  piny
//
//  Created by John Grishin on 15/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import SwiftData

@Model
class Pin: Identifiable, Equatable {
  @Attribute(.unique) var id: UUID
  var title: String?
  var desc: String?
  var privacy: PinPrivacy
  var state: PinState
  @Relationship(.unique, deleteRule: .cascade)
  var link: PinLink
  var tags: [PinTag] = []
  var createdAt: Date
  var updatedAt: Date

  init(
    id: UUID,
    title: String? = nil,
    desc: String? = nil,
    privacy: PinPrivacy,
    state: PinState,
    link: PinLink,
    tags: [PinTag],
    createdAt: Date,
    updatedAt: Date
  ) {
    self.id = id
    self.title = title
    self.desc = desc
    self.privacy = privacy
    self.state = state
    self.link = link
    self.tags = tags
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  convenience init(from pin: PinDTO) {
    self.init(
      id: pin.id,
      title: pin.title,
      desc: pin.description,
      privacy: pin.privacy,
      state: pin.state,
      link: PinLink(from: pin.link),
      tags: pin.tags.map { PinTag(from: $0) },
      createdAt: pin.createdAt,
      updatedAt: pin.updatedAt
    )
  }
}


enum PinState: String, Codable {
  case active = "active"
  case removed = "removed"
}

enum PinPrivacy: String, Codable {
  case `public` = "public"
  case `private` = "private"
}

struct PinDTO: Hashable, Codable, Identifiable, Equatable {
  var id: UUID
  var title: String?
  var description: String?
  var state: PinState
  var privacy: PinPrivacy
  var link: PinLinkDTO
  var tags: [PinTagDTO]
  var createdAt: Date
  var updatedAt: Date

  struct Payload: Codable {
    var title: String?
    var description: String?
    var state: PinState?
    var privacy: PinPrivacy?
    var tags: [String]?
  }
}

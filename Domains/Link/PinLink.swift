//
//  PinLink.swift
//  piny
//
//  Created by John Grishin on 21/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import SwiftData

@Model
class PinLink: Identifiable, Equatable, Hashable {
  @Attribute(.unique)
  var id: UUID
  @Attribute(.unique)
  var url: URL

  init(id: UUID, url: URL) {
    self.id = id
    self.url = url
  }

  convenience init(from link: PinLinkDTO) {
    self.init(
      id: link.id,
      url: link.url
    )
  }

  static func == (lhs: PinLink, rhs: PinLink) -> Bool {
    return lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

struct PinLinkDTO: Hashable, Codable, Identifiable {
  var id: UUID
  var url: URL
}

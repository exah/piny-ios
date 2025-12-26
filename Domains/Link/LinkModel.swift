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
class LinkModel: Identifiable, Equatable, Hashable {
  @Attribute(.unique)
  var id: UUID

  @Attribute(.unique)
  var url: URL

  init(id: UUID, url: URL) {
    self.id = id
    self.url = url
  }

  convenience init(from link: LinkDTO) {
    self.init(
      id: link.id,
      url: link.url
    )
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: LinkModel, rhs: LinkModel) -> Bool {
    return lhs.id == rhs.id
  }

  typealias Group = [URL: LinkModel]
  static func group(_ links: [LinkModel]) -> Group {
    Dictionary(uniqueKeysWithValues: links.map { ($0.url, $0) })
  }

  static func resolve(with dto: LinkDTO, links: Group) -> LinkModel {
    links[dto.url] ?? LinkModel(from: dto)
  }
}

//
//  PinDTO.swift
//  piny
//
//  Created by J. Grishin on 25/12/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import Foundation

struct PinDTO: Hashable, Codable, Identifiable, Equatable {
  var id: UUID
  var title: String
  var description: String
  var privacy: PinPrivacy
  var link: LinkDTO
  var tags: [TagDTO]
  var createdAt: Date
  var updatedAt: Date
}

extension PreviewContent {
  static let pinsDTO: [PinDTO] = load("preview-pins.json")
}

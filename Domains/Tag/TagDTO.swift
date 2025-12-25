//
//  TagDTO.swift
//  piny
//
//  Created by J. Grishin on 25/12/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import Foundation

struct TagDTO: Hashable, Equatable, Codable, Identifiable {
  var id: UUID
  var name: String
}

extension PreviewContent {
  static let tagsDTO: [TagDTO] = load("preview-tags.json")
}

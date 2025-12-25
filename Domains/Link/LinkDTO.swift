//
//  LinkDTO.swift
//  piny
//
//  Created by J. Grishin on 25/12/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import Foundation

struct LinkDTO: Hashable, Codable, Identifiable {
  var id: UUID
  var url: URL
}

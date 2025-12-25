//
//  UserDTO.swift
//  piny
//
//  Created by J. Grishin on 25/12/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import Foundation

struct UserDTO: Identifiable, Codable {
  var id: UUID
  var name: String
  var email: String
}

extension PreviewContent {
  static let userDTO: UserDTO = load("preview-user.json")
}

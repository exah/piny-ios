//
//  User.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import SwiftData

@Model
class User: Identifiable, Equatable {
  @Attribute(.unique) var id: UUID
  var name: String
  @Attribute(.unique) var email: String
  var token: String?

  init(id: UUID, name: String, email: String, token: String? = nil) {
    self.id = id
    self.name = name
    self.email = email
    self.token = token
  }

  convenience init(from user: UserDTO) {
    self.init(
      id: user.id,
      name: user.name,
      email: user.email,
      token: user.token,
    )
  }
}

struct UserDTO: Identifiable, Codable {
  var id: UUID
  var name: String
  var email: String
  var token: String?
}

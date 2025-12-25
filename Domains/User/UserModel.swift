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
class UserModel: Identifiable, Equatable {
  @Attribute(.unique)
  var id: UUID
  var name: String
  @Attribute(.unique)
  var email: String

  init(id: UUID, name: String, email: String) {
    self.id = id
    self.name = name
    self.email = email
  }

  convenience init(from user: UserDTO) {
    self.init(
      id: user.id,
      name: user.name,
      email: user.email,
    )
  }

  static func == (lhs: UserModel, rhs: UserModel) -> Bool {
    return lhs.id == rhs.id
  }
}

extension PreviewContent {
  static let user: UserModel = UserModel(from: userDTO)
}

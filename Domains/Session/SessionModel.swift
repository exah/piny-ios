//
//  Authorization.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import SwiftData

@Model
class SessionModel: Identifiable, Equatable {
  @Attribute(.unique)
  var id: UUID = UUID()
  @Attribute(.unique)
  var token: String
  var expiresAt: Date

  init(token: String, expiresAt: Date) {
    self.token = token
    self.expiresAt = expiresAt
  }

  convenience init(from session: SessionDTO) {
    self.init(
      token: session.token,
      expiresAt: session.expiresAt
    )
  }

  static func == (lhs: SessionModel, rhs: SessionModel) -> Bool {
    return lhs.id == rhs.id
  }
}

struct SessionDTO: Codable {
  let token: String
  let expiresAt: Date

  struct Payload: Codable {
    let user: String
    let pass: String
    let device: SessionDevice
  }
}

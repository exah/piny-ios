//
//  Authorisation.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import SwiftData

@Model
class Session: Identifiable, Equatable {
  var token: String
  var expiresAt: Date

  init(token: String, expiresAt: Date) {
    self.token = token
    self.expiresAt = expiresAt
  }

  convenience init(from auth: Authorisation) {
    self.init(
      token: auth.token,
      expiresAt: auth.expiresAt
    )
  }

  static func == (lhs: Session, rhs: Session) -> Bool {
    return lhs.token == rhs.token
  }
}

struct Authorisation: Codable {
  let token: String
  let expiresAt: Date

  struct Payload: Codable {
    let user: String
    let pass: String
    let device: Device
  }
}

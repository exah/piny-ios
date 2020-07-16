//
//  User.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation

struct User: Codable {
  let id: UUID
  let name: String
  let email: String
}

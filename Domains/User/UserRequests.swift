//
//  UserRequests.swift
//  piny
//
//  Created by J. Grishin on 25/12/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

struct UserRequests {
  static func get(name: String) async throws -> UserDTO {
    try await Piny.api.get(
      UserDTO.self,
      path: "/\(name)"
    )
  }
}

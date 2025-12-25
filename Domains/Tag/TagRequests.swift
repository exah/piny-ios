//
//  TagRequests.swift
//  piny
//
//  Created by J. Grishin on 25/12/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

enum TagRequests {
  static func fetch() async throws -> [TagDTO] {
    let result = try await Piny.api.get(
      [TagDTO].self,
      path: "/tags"
    )

    Piny.log("Loaded tags: \(result.count)")
    return result
  }
}

//
//  PinsRequests.swift
//  piny
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Combine
import Foundation
import SwiftData
import SwiftUI

struct PinRequests {
  static func fetch() async throws -> [PinDTO] {
    let result = try await Piny.api.get(
      [PinDTO].self,
      path: "/bookmarks"
    )

    Piny.log("Loaded pins: \(result.count)")
    return result
  }

  static func create(
    title: String? = nil,
    description: String? = nil,
    url: URL,
    privacy: PinPrivacy
  ) async throws -> PinyMessageResponse {
    try await Piny.api.post(
      PinyMessageResponse.self,
      path: "/bookmarks",
      json: [
        "url": url.absoluteString,
        "privacy": privacy.rawValue,
        "title": title,
        "description": description,
      ]
    )
  }

  static func get(_ pin: PinModel) async throws -> PinDTO {
    try await Piny.api.get(
      PinDTO.self,
      path: "/bookmarks/\(pin.id.uuidString.lowercased())"
    )
  }

  static func edit(
    _ pin: PinModel,
    url: URL,
    title: String,
    description: String,
    privacy: PinPrivacy,
    tags: [String]
  ) async throws -> PinDTO {
    try await Piny.api.patch(
      PinyMessageResponse.self,
      path: "/bookmarks/\(pin.id.uuidString.lowercased())",
      json: PinDTO.Payload(
        url: url,
        title: title,
        description: description,
        privacy: privacy,
        tags: tags
      )
    )

    return try await get(pin)
  }

  static func remove(_ pin: PinModel) async throws -> PinyMessageResponse {
    try await Piny.api.delete(
      PinyMessageResponse.self,
      path: "/bookmarks/\(pin.id.uuidString.lowercased())"
    )
  }
}

//
//  PinsRequests.swift
//  piny
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation

enum PinRequests {
  static func fetch() async throws -> [PinDTO] {
    let result = try await Piny.api.get(
      [PinDTO].self,
      path: "/bookmarks"
    )

    Piny.log("Loaded pins: \(result.count)")
    return result
  }

  struct CreatePayload: Codable {
    var url: URL
    var title: String?
    var description: String?
    var privacy: PinPrivacy
  }

  static func create(
    title: String? = nil,
    description: String? = nil,
    url: URL,
    privacy: PinPrivacy
  ) async throws -> MessageDTO {
    try await Piny.api.post(
      MessageDTO.self,
      path: "/bookmarks",
      json: CreatePayload(
        url: url,
        title: title,
        description: description,
        privacy: privacy,
      )
    )
  }

  static func get(_ pin: PinModel) async throws -> PinDTO {
    try await Piny.api.get(
      PinDTO.self,
      path: "/bookmarks/\(pin.id.uuidString.lowercased())"
    )
  }

  struct EditPayload: Codable {
    var url: URL
    var title: String
    var description: String
    var privacy: PinPrivacy
    var tags: [String]
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
      MessageDTO.self,
      path: "/bookmarks/\(pin.id.uuidString.lowercased())",
      json: EditPayload(
        url: url,
        title: title,
        description: description,
        privacy: privacy,
        tags: tags
      )
    )

    return try await get(pin)
  }

  static func remove(_ pin: PinModel) async throws -> MessageDTO {
    try await Piny.api.delete(
      MessageDTO.self,
      path: "/bookmarks/\(pin.id.uuidString.lowercased())"
    )
  }
}

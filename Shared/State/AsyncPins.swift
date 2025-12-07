//
//  AsyncPins.swift
//  piny
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Combine
import Foundation
import SwiftData
import SwiftUI

@Observable
class AsyncPins: Async {
  @MainActor
  init(_ initial: [Pin] = [], modelContext: ModelContext? = nil) {
    super.init(modelContext: modelContext)
    initial.forEach { self.modelContext.insert($0) }
  }

  @MainActor
  func fetch() async throws -> [PinDTO] {
    try await capture {
      let result = try await Piny.api.get(
        [PinDTO].self,
        path: "/bookmarks"
      )

      Piny.log("Loaded pins: \(result.count)")

      do {
        try self.modelContext.transaction {
          let pins = try self.modelContext.fetch(FetchDescriptor<Pin>())
          let tags = try self.modelContext.fetch(FetchDescriptor<PinTag>())

          // Remove pins that no longer exist on server
          let serverPinIds = Set(result.map { $0.id })
          pins.filter { !serverPinIds.contains($0.id) }.forEach {
            self.modelContext.delete($0)
          }

          for item in result {
            if let existing = pins.first(where: { $0.id == item.id }) {
              existing.update(from: item, tags: tags)
            } else {
              let pin = Pin(from: item, tags: tags)
              self.modelContext.insert(pin)
            }
          }
        }
      } catch {
        Piny.log("Fetch transaction failed: \(error)", .error)
        throw error
      }

      return result
    }
  }

  @MainActor
  func create(
    title: String? = nil,
    description: String? = nil,
    url: URL,
    privacy: PinPrivacy
  ) async throws -> API.Message {
    try await capture {
      try await Piny.api.post(
        API.Message.self,
        path: "/bookmarks",
        json: [
          "url": url.absoluteString,
          "privacy": privacy.rawValue,
          "title": title,
          "description": description,
        ]
      )
    }
  }

  @MainActor
  func get(_ pin: Pin) async throws -> PinDTO {
    try await capture {
      let result = try await Piny.api.get(
        PinDTO.self,
        path: "/bookmarks/\(pin.id.uuidString.lowercased())"
      )

      do {
        let tags = try self.modelContext.fetch(FetchDescriptor<PinTag>())
        pin.update(from: result, tags: tags)
      } catch {
        Piny.log("Failed to fetch tags for update: \(error)", .error)
        throw error
      }

      return result
    }
  }

  @MainActor
  func edit(
    _ pin: Pin,
    title: String? = nil,
    description: String? = nil,
    privacy: PinPrivacy? = nil,
    tags: [String] = []
  ) async throws -> PinDTO {
    _ = try await Piny.api.patch(
      API.Message.self,
      path: "/bookmarks/\(pin.id.uuidString.lowercased())",
      json: PinDTO.Payload(
        title: title?.isEmpty == true ? nil : title,
        description: description?.isEmpty == true ? nil : description,
        privacy: privacy,
        tags: tags
      )
    )

    return try await self.get(pin)
  }

  @MainActor
  func remove(_ pin: Pin) async throws {
    self.modelContext.delete(pin)

    do {
      _ = try await Piny.api.delete(
        API.Message.self,
        path: "/bookmarks/\(pin.id.uuidString.lowercased())"
      )
    } catch {
      self.modelContext.insert(pin)
      throw error
    }
  }
}

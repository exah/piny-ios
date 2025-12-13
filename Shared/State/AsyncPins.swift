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

struct AsyncPinsResult {
  let fetch = AsyncResult<[PinDTO]>()
  let get = AsyncResult<PinDTO>()
  let create = AsyncResult<PinyMessageResponse>()
  let edit = AsyncResult<PinDTO>()
  let remove = AsyncResult<PinyMessageResponse>()
}

@Observable
class AsyncPins: Async {
  let result = AsyncPinsResult()

  @MainActor
  init(_ initial: [Pin] = [], modelContext: ModelContext? = nil) {
    super.init(modelContext: modelContext)
    initial.forEach { self.modelContext.insert($0) }
  }

  @MainActor
  @discardableResult
  func fetch() async throws -> [PinDTO] {
    try await result.fetch.capture {
      let result = try await PinsRequests.fetch()

      do {
        try self.modelContext.transaction {
          let pins = try self.modelContext.fetch(FetchDescriptor<Pin>())
          let tags = try self.modelContext.fetch(FetchDescriptor<PinTag>())

          // Remove pins that no longer exist on server
          let serverPinIds = Set(result.map { $0.id })
          pins.filter { !serverPinIds.contains($0.id) }
            .forEach {
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
  @discardableResult
  func create(
    title: String? = nil,
    description: String? = nil,
    url: URL,
    privacy: PinPrivacy
  ) async throws -> PinyMessageResponse {
    try await result.create.capture {
      try await PinsRequests.create(
        title: title,
        description: description,
        url: url,
        privacy: privacy
      )
    }
  }

  @MainActor
  @discardableResult
  func get(_ pin: Pin) async throws -> PinDTO {
    try await result.get.capture {
      let result = try await PinsRequests.get(pin)

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
  @discardableResult
  func edit(
    _ pin: Pin,
    title: String? = nil,
    description: String? = nil,
    privacy: PinPrivacy? = nil,
    tags: [String] = []
  ) async throws -> PinDTO {
    try await result.edit.capture {
      let result = try await PinsRequests.edit(
        pin,
        title: title,
        description: description,
        privacy: privacy,
        tags: tags,
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
  @discardableResult
  func remove(_ pin: Pin) async throws -> PinyMessageResponse {
    try await result.remove.capture {
      self.modelContext.delete(pin)

      do {
        return try await PinsRequests.remove(pin)
      } catch {
        self.modelContext.insert(pin)
        throw error
      }
    }
  }

}

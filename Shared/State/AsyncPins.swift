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
  let fetch = Async<[Pin]>()
  let get = Async<Pin>()
  let create = Async<PinyMessageResponse>()
  let edit = Async<Pin>()
  let remove = Async<PinyMessageResponse>()
}

@Observable
class AsyncPins {
  let result = AsyncPinsResult()
  let pinsActor = PinsActor(modelContainer: .shared)
  let tagsActor = TagsActor(modelContainer: .shared)

  init(_ initial: [Pin] = []) {
    Task {
      try await pinsActor.insert(pins: initial)
      result.fetch.status = .success(initial)
    }
  }

  @discardableResult
  func fetch() async throws -> [Pin] {
    try await result.fetch.capture {
      let result: [PinDTO]

      do {
        result = try await PinsRequests.fetch()
      } catch {
        Piny.log("Pins load failed: \(error)", .error)
        throw error
      }

      do {
        try await pinsActor.sync(result)
      } catch {
        Piny.log("Pins sync failed: \(error)", .error)
        throw error
      }

      return try await pinsActor.fetch()
    }
  }

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

  @discardableResult
  func get(_ pin: Pin) async throws -> Pin {
    try await result.get.capture {
      let result = try await PinsRequests.get(pin)

      do {
        let tags = try await tagsActor.fetch()
        pin.update(from: result, tags: tags)
      } catch {
        Piny.log("Failed to fetch tags for update: \(error)", .error)
        throw error
      }

      return try await pinsActor.get(by: result.id)
    }
  }

  @discardableResult
  func edit(
    _ pin: Pin,
    url: URL,
    title: String,
    description: String,
    privacy: PinPrivacy,
    tags: [String]
  ) async throws -> Pin {
    try await result.edit.capture {
      let result: PinDTO
      do {
        result = try await PinsRequests.edit(
          pin,
          url: url,
          title: title,
          description: description,
          privacy: privacy,
          tags: tags,
        )
      } catch {
        Piny.log("Failed to edit pin: \(error)", .error)
        throw error
      }

      do {
        let tags = try await tagsActor.fetch()
        pin.update(from: result, tags: tags)
      } catch {
        Piny.log("Failed to fetch tags for update: \(error)", .error)
        throw error
      }

      return try await pinsActor.get(by: result.id)
    }
  }

  @discardableResult
  func remove(_ pin: Pin) async throws -> PinyMessageResponse {
    try await result.remove.capture {
      try await pinsActor.delete(pin)

      do {
        return try await PinsRequests.remove(pin)
      } catch {
        try await pinsActor.insert(pin)
        throw error
      }
    }
  }

}

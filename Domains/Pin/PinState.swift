//
//  PinState.swift
//  piny
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Combine
import Foundation
import SwiftData
import SwiftUI

struct AsyncPinResult {
  let fetch = Async<[PinModel]>()
  let get = Async<PinModel>()
  let create = Async<PinyMessageResponse>()
  let edit = Async<PinModel>()
  let remove = Async<PinyMessageResponse>()
}

@Observable
class PinState {
  let result = AsyncPinResult()
  let pinActor = PinActor(modelContainer: .shared)
  let tagActor = TagActor(modelContainer: .shared)

  init(_ initial: [PinModel] = []) {
    Task {
      try await pinActor.insert(pins: initial)
      result.fetch.status = .success(initial)
    }
  }

  @discardableResult
  func fetch() async throws -> [PinModel] {
    try await result.fetch.capture {
      let result: [PinDTO]

      do {
        result = try await PinRequests.fetch()
      } catch {
        Piny.log("Pins load failed: \(error)", .error)
        throw error
      }

      do {
        try await pinActor.sync(result)
      } catch {
        Piny.log("Pins sync failed: \(error)", .error)
        throw error
      }

      return try await pinActor.fetch()
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
      try await PinRequests.create(
        title: title,
        description: description,
        url: url,
        privacy: privacy
      )
    }
  }

  @discardableResult
  func get(_ pin: PinModel) async throws -> PinModel {
    try await result.get.capture {
      let result = try await PinRequests.get(pin)

      do {
        let tags = try await tagActor.fetch()
        pin.update(from: result, tags: tags)
      } catch {
        Piny.log("Failed to fetch tags for update: \(error)", .error)
        throw error
      }

      return try await pinActor.get(by: result.id)
    }
  }

  @discardableResult
  func edit(
    _ pin: PinModel,
    url: URL,
    title: String,
    description: String,
    privacy: PinPrivacy,
    tags: [String]
  ) async throws -> PinModel {
    try await result.edit.capture {
      let result: PinDTO
      do {
        result = try await PinRequests.edit(
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
        let tags = try await tagActor.fetch()
        pin.update(from: result, tags: tags)
      } catch {
        Piny.log("Failed to fetch tags for update: \(error)", .error)
        throw error
      }

      return try await pinActor.get(by: result.id)
    }
  }

  @discardableResult
  func remove(_ pin: PinModel) async throws -> PinyMessageResponse {
    try await result.remove.capture {
      try await pinActor.delete(pin)

      do {
        return try await PinRequests.remove(pin)
      } catch {
        try await pinActor.insert(pin)
        throw error
      }
    }
  }

}

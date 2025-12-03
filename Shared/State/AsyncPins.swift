//
//  AsyncPins.swift
//  piny
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import PromiseKit
import Combine
import SwiftData
import SwiftUI

@Observable
class AsyncPins: Async {
  @MainActor
  init(_ initial: [Pin] = [], modelContext: ModelContext? = nil) {
    super.init(modelContext: modelContext)
    initial.forEach { self.modelContext.insert($0) }
  }

  func fetch() -> Promise<[PinDTO]> {
    capture {
      Piny.api.get(
        [PinDTO].self,
        path: "/bookmarks"
      ).get { pins in
        Piny.log("Loaded pins: \(pins.count)")

        let existing = (try? self.modelContext.fetch(FetchDescriptor<Pin>())) ?? []
        let allTags = (try? self.modelContext.fetch(FetchDescriptor<PinTag>())) ?? []

        // Remove pins that no longer exist on server
        let serverPinIds = Set(pins.map { $0.id })
        existing.filter { !serverPinIds.contains($0.id) }.forEach { self.modelContext.delete($0) }

        // Update or insert pins
        for pinDTO in pins {
          if let existingPin = existing.first(where: { $0.id == pinDTO.id }) {
            existingPin.update(from: pinDTO, existingTags: allTags)
          } else {
            let pin = Pin(from: pinDTO)
            self.modelContext.insert(pin)
          }
        }
      }
    }
  }

  func create(
    title: String? = nil,
    description: String? = nil,
    url: URL,
    privacy: PinPrivacy
  ) -> Promise<API.Message> {
    capture {
      Piny.api.post(
        API.Message.self,
        path: "/bookmarks",
        data: [
          "url": url.absoluteString,
          "privacy": privacy.rawValue,
          "title": title,
          "description": description,
        ]
      )
    }
  }

  func edit(
    _ pin: Pin,
    title: String? = nil,
    description: String? = nil,
    privacy: PinPrivacy? = nil,
    tags: [String] = []
  ) -> Promise<PinDTO> {
    firstly {
      Piny.api.patch(
        API.Message.self,
        path: "/bookmarks/\(pin.id.uuidString.lowercased())",
        data: PinDTO.Payload(
          title: title?.isEmpty == true ? nil : title,
          description: description?.isEmpty == true ? nil : description,
          privacy: privacy,
          tags: tags
        )
      )
    }.then { _ in
      Piny.api.get(
        PinDTO.self,
        path: "/bookmarks/\(pin.id.uuidString.lowercased())"
      )
    }.get { result in
      let allTags = (try? self.modelContext.fetch(FetchDescriptor<PinTag>())) ?? []
      pin.update(from: result, existingTags: allTags)
    }
  }

  func remove(_ pin: Pin) -> Promise<Void> {
    self.modelContext.delete(pin)

    return Piny.api.delete(
      API.Message.self,
      path: "/bookmarks/\(pin.id.uuidString.lowercased())"
    ).done { _ in }.recover { error in
      self.modelContext.insert(pin)
      throw error
    }
  }
}

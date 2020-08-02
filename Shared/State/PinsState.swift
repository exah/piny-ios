//
//  PinsState.swift
//  piny
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import PromiseKit

final class PinsState: AsyncState {
  @Published var pins: [Pin] = []
  @Published var isLoading: Bool = false

  init(_ initial: [Pin]? = nil) {
    if let pins = initial {
      self.pins = pins
    } else {
      let sort = NSSortDescriptor(key: "createdAt", ascending: false)
      let pins = Piny.storage.fetch(Pin.self, sortDescriptors: [sort])

      if pins.count > 0 {
        self.pins = pins
      }

      log("Fetched from store pins(\(pins.count)): \(pins)")
    }
  }

  func fetch() -> Promise<[Pin]> {
    capture {
      Piny.api.get(
        [Pin].self,
        path: "/bookmarks"
      ).get { pins in
        self.pins = pins

        Piny.storage.remove(Pin.self)
        Piny.storage.save(pins)
      }
    }
  }

  func create(
    title: String? = nil,
    description: String? = nil,
    url: URL,
    privacy: Pin.Privacy
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
    url: URL,
    privacy: Pin.Privacy
  ) -> Promise<Pin> {
    firstly {
      Piny.api.patch(
        API.Message.self,
        path: "/bookmarks/\(pin.getId())",
        data: [
          "url": url.absoluteString,
          "privacy": privacy.rawValue,
          "title": title,
          "description": description,
        ]
      )
    }.then { _ in
      Piny.api.get(
        Pin.self,
        path: "/bookmarks/\(pin.getId())"
      )
    }.get { pin in
      Piny.storage.save(pin)
    }
  }

  func remove(_ pin: Pin) -> Promise<Void> {
    firstly {
      Piny.api.delete(
        API.Message.self,
        path: "/bookmarks/\(pin.getId())"
      )
    }.done { _ in
      if let index = self.pins.firstIndex(of: pin) {
        Piny.storage.remove(pin)
        self.pins.remove(at: index)
      }
    }
  }
}

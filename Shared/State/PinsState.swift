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

      Piny.log("Fetched from store pins(\(pins.count)): \(pins)")
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
    privacy: Pin.Privacy? = nil,
    tags: [String] = []
  ) -> Promise<Pin> {
    firstly {
      Piny.api.patch(
        API.Message.self,
        path: "/bookmarks/\(pin.getId())",
        data: Pin.Payload(
          title: title?.isEmpty == true ? nil : title,
          description: description?.isEmpty == true ? nil : description,
          privacy: privacy,
          tags: tags
        )
      )
    }.then { _ in
      Piny.api.get(
        Pin.self,
        path: "/bookmarks/\(pin.getId())"
      )
    }.get { result in
      if let index = self.pins.firstIndex(of: pin) {
        self.pins[index] = result
      }

      Piny.storage.save(result)
    }
  }

  func remove(_ pin: Pin) -> Promise<Void> {
    guard let index = self.pins.firstIndex(of: pin) else {
      return Promise(error: Piny.Error.runtimeError("Invalid pin index"))
    }

    self.pins.remove(at: index)

    return Piny.api.delete(
      API.Message.self,
      path: "/bookmarks/\(pin.getId())"
    ).done { _ in
      Piny.storage.remove(pin)
    }.recover { error in
      self.pins.insert(pin, at: index)
      throw error
    }
  }
}

//
//  PinsState.swift
//  piny
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import PromiseKit

let PREVIEW_PINS: [Pin] = loadJSON("pins.json")

final class PinsState: ObservableObject {
  @Published var pins: [Pin] = []
  @Published var task: URLSessionDataTask?

  var isLoading: Bool {
    return task?.isLoading == true
  }

  init(_ initial: [Pin]? = nil) {
    if let pins = initial {
      self.pins = pins
    } else {
      let pins = Piny.storage.fetch(Pin.self)

      if pins.count > 0 {
        self.pins = pins
      }

      log("Fetched from store pins(\(pins.count)): \(pins)")
    }
  }

  func fetch(for user: User) -> Promise<[Pin]> {
    firstly {
      Piny.api.get(
        [Pin].self,
        path: "/\(user.name)/bookmarks"
      ) { task in
        self.task?.cancel()
        self.task = task
      }
      .ensure {
        self.task = nil
      }
    }.get { pins in
      self.pins = pins

      Piny.storage.remove(Pin.self)
      Piny.storage.save(pins)
    }
  }

  func create(
    for user: User,
    title: String? = nil,
    description: String? = nil,
    url: URL,
    privacy: PrivacyType
  ) -> Promise<API.Message> {
    Piny.api.post(
      API.Message.self,
      path: "/\(user.name)/bookmarks",
      data: [
        "url": url.absoluteString,
        "privacy": privacy.rawValue,
        "title": title,
        "description": description,
      ]
    ) { task in
      self.task?.cancel()
      self.task = task
    }.ensure {
      self.task = nil
    }
  }
}

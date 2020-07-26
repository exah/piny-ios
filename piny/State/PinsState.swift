//
//  PinsState.swift
//  piny
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation

let PREVIEW_PINS: [Pin] = loadJSON("pins.json")

final class PinsState: ObservableObject {
  @Published var pins: [Pin] = []
  @Published var task: URLSessionDataTask?

  init(_ initial: [Pin]? = nil) {
    if let pins = initial {
      self.pins = pins
    } else {
      let pins = Piny.storage.fetch(Pin.self)

      if pins.count > 0 {
        self.pins = pins
      }

      log("Fetched pins(\(pins.count)): \(pins)")
    }
  }

  func fetchPins(user: User, onCompletion: API.Completion<Void>? = nil) {
    task?.cancel()
    task = Piny.api.get([Pin].self, path: "/\(user.name)/bookmarks") { result in
      switch result {
        case .success(var pins):
          log("Pins: \(pins)")

          self.pins = pins
          self.task = nil

          Piny.storage.remove(Pin.self)
          Piny.storage.save(&pins)

          onCompletion?(.success(()))
        case .failure(let error):
          log(error, level: .error)

          onCompletion?(.failure(error))
      }
    }
  }
}

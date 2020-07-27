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

      log("Fetched pins(\(pins.count)): \(pins)")
    }
  }

  func fetch(
    for user: User,
    onCompletion: API.Completion<Void>? = nil
  ) {
    task?.cancel()
    task = Piny.api.get(
      [Pin].self,
      path: "/\(user.name)/bookmarks"
    ) { result in
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

  func create(
    for user: User,
    title: String? = nil,
    description: String? = nil,
    url: URL,
    privacy: PrivacyType,
    onCompletion: API.Completion<Void>? = nil
  ) {
    task?.cancel()
    task = Piny.api.post(
      API.Message.self,
      path: "/\(user.name)/bookmarks",
      data: [
        "url": url.absoluteString,
        "privacy": privacy.rawValue,
        "title": title,
        "description": description,
      ]
    ) { result in
      switch result {
        case .success:
          self.task = nil
          self.fetch(for: user) { result in
            onCompletion?(result)
          }
        case .failure(let error):
          log(error, level: .error)
          onCompletion?(.failure(error))
      }
    }
  }
}

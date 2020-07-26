//
//  UserData.swift
//  piny
//
//  Created by John Grishin on 14/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI
import Combine
import CoreData

let PREVIEW_PINS: [Pin] = loadJSON("pins.json")

extension URLSessionDataTask {
  var isLoading: Bool {
    return self.state == .running
  }
}

final class UserState: ObservableObject {
  @Published var pins: [Pin] = []
  @Published var user: User?

  @Published var loginTask: URLSessionDataTask?
  @Published var userTask: URLSessionDataTask?
  @Published var pinsTask: URLSessionDataTask?
  
  init(initialPins: [Pin]? = nil, initialUser: User? = nil) {
    if let pins = initialPins {
      self.pins = pins
    } else {
      let pins = Piny.storage.fetch(Pin.self)
      log("Fetched pins(\(pins.count)): \(pins)")

      if pins.count > 0 {
        self.pins = pins
      }
    }

    if let user = initialUser {
      self.user = user
      Piny.api.token = user.token
    } else {
      let users = Piny.storage.fetch(User.self, limit: 1)
      log("Fetched users(\(users.count)): \(users)")

      if users.count == 1 {
        self.user = users[0]
        Piny.api.token = users[0].token
      }
    }
  }


  func login(
    user: String,
    pass: String,
    onCompletion: API.Completion<Void>? = nil
  ) {
    loginTask?.cancel()
    loginTask = Piny.api.post(
      path: "/login",
      data: [ "user": user, "pass": pass ]
    ) { (result: API.Result<Authorisation>) in
      switch result {
        case .success(let json):
          log("Token: \(json.token)")
          Piny.api.token = json.token

          self.fetchUser(user: user) { result in
            switch result {
              case .success():
                self.user?.token = json.token

                if var user = self.user {
                  Piny.storage.remove(User.self)
                  Piny.storage.save(&user)
                }

                onCompletion?(.success(()))
              case .failure(let error):
                onCompletion?(.failure(error))
            }
          }

        case .failure(let error):
          log(error, level: .error)
          
          onCompletion?(.failure(error))
      }
    }
  }

  func fetchUser(
    user: String,
    onCompletion: API.Completion<Void>? = nil
  ) {
    userTask?.cancel()
    userTask = Piny.api.get(path: "/\(user)") { (result: API.Result<User>) in
      switch result {
        case .success(let json):
          log("User: \(user)")

          self.user = json
          
          onCompletion?(.success(()))
        case .failure(let error):
          log(error, level: .error)

          onCompletion?(.failure(error))
      }
    }
  }

  func fetchPins(onCompletion: API.Completion<Void>? = nil) {
    guard let userName = user?.name else {
      log("Please /login first, then fetch user info")
      return
    }

    pinsTask?.cancel()
    pinsTask = Piny.api.get(path: "/\(userName)/bookmarks") { (result: API.Result<[Pin]>) in
      switch result {
        case .success(var pins):
          log("Pins: \(pins)")
          self.pins = pins

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

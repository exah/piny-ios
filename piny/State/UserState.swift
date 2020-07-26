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
  
  convenience init(initialPins: [Pin]? = nil, initialUser: User? = nil) {
    self.init(initialPins: initialPins)
    self.init(initialUser: initialUser)
  }

  init(initialPins: [Pin]?) {
    if let pins = initialPins {
      self.pins = pins
    }
  }

  init(initialUser: User?) {
    func insert(_ user: User) {
      self.user = user
      Piny.api.token = user.token
    }

    if let user = initialUser {
      insert(user)
    } else {
      let users = Piny.storage.fetch(User.self, limit: 1)

      if users.count == 1 {
        insert(users[0])
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

          onCompletion?(.success(()))
        case .failure(let error):
          log(error, level: .error)

          onCompletion?(.failure(error))
      }
    }
  }
}

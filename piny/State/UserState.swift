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

let PREVIEW_USER: User = loadJSON("user.json")

final class UserState: ObservableObject {
  @Published var user: User?
  @Published var task: URLSessionDataTask?

  var isLoading: Bool {
    return task?.isLoading == true
  }

  var isLoggedIn: Bool {
    return user?.token != nil
  }

  init(_ initial: User? = nil) {
    if let user = initial {
      self.user = user
      Piny.api.token = user.token
    } else {
      let users = Piny.storage.fetch(User.self, limit: 1)

      if users.count == 1 {
        self.user = users[0]
        Piny.api.token = users[0].token
      }

      log("Fetched users(\(users.count)): \(users)")
    }
  }


  func login(
    name: String,
    pass: String,
    onCompletion: API.Completion<Void>? = nil
  ) {
    task?.cancel()
    task = Piny.api.post(
      Authorisation.self,
      path: "/login",
      data: [ "user": name, "pass": pass ]
    ) { result in
      switch result {
        case .success(let auth):
          log("Token: \(auth.token)")

          Piny.api.token = auth.token

          self.task = nil
          self.fetchUser(name: name) { result in
            switch result {
              case .success():
                self.user?.token = auth.token

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
    name: String,
    onCompletion: API.Completion<Void>? = nil
  ) {
    task?.cancel()
    task = Piny.api.get(User.self, path: "/\(name)") { result in
      switch result {
        case .success(let user):
          log("User: \(user)")

          self.user = user
          self.task = nil

          onCompletion?(.success(()))
        case .failure(let error):
          log(error, level: .error)

          onCompletion?(.failure(error))
      }
    }
  }
}

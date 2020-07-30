//
//  UserData.swift
//  piny
//
//  Created by John Grishin on 14/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import PromiseKit

let PREVIEW_USER: User = loadJSON("user.json")

final class UserState: AsyncState {
  @Published var user: User?

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

      log("Fetched from store users(\(users.count)): \(users)")
    }
  }

  private func fetchUser(name: String) -> Promise<User> {
    Piny.api.get(
      User.self,
      path: "/\(name)",
      task: &task
    )
  }

  func login(name: String, pass: String) -> Promise<Void> {
    firstly {
      Piny.api.post(
        Authorisation.self,
        path: "/login",
        data: [ "user": name, "pass": pass ],
        task: &task
      )
    }.get { auth in
      log("Token: \(auth.token)")

      Piny.api.token = auth.token
    }.then { auth in
      self.fetchUser(name: name).map { user in (auth, user) }
    }.done { auth, user in
      log("User: \(user)")

      self.user = user
      self.user?.token = auth.token

      Piny.storage.remove(User.self)
      Piny.storage.save(self.user!)
    }
  }
}

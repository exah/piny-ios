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

final class UserData: ObservableObject {
  private var api = API(baseURL: "https://dev.piny.link")
  
  @Published var pins: [Pin]?
  @Published var user: User?
  @Published var isLoggedIn: Bool = false
  
  init(initialPins: [Pin]? = nil) {
    self.pins = initialPins
  }

  private var loginTask: URLSessionDataTask?
  func login(
    user: String,
    pass: String,
    onSuccess: @escaping () -> Void
  ) {
    loginTask?.cancel()
    loginTask = api.post(
      path: "/login",
      data: [ "user": user, "pass": pass ]
    ) { (result: API.Result<Authorisation>) in
      switch result {
        case .success(let json):
          print("Token: \(json.token)")
          self.api.token = json.token

          self.fetchUser(user: user) {
            self.isLoggedIn = true

            onSuccess()
        }

        case .failure(let error):
          print(error)
      }
    }
  }

  private var userTask: URLSessionDataTask?
  func fetchUser(
    user: String,
    onSuccess: @escaping () -> Void
  ) {
    userTask?.cancel()
    userTask = api.get(path: "/\(user)") { (result: API.Result<User>) in
      switch result {
        case .success(let json):
          print("User: \(user)")
          self.user = json

          onSuccess()
        case .failure(let error):
          print(error)
      }
    }
  }

  private var userPinsTask: URLSessionDataTask?
  func fetchUserPins(onSuccess: @escaping () -> Void) {
    userPinsTask?.cancel()

    guard let userName = user?.name else {
      print("Please /login first, then fetch user info")
      return
    }

    userPinsTask = api.get(path: "/\(userName)/bookmarks") { (result: API.Result<[Pin]>) in
      switch result {
        case .success(let json):
          print("Pins: \(json)")
          self.pins = json

          onSuccess()
        case .failure(let error):
          print(error)
      }
    }
  }
}

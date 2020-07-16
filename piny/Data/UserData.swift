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
  
  init(pins: [Pin]? = nil) {
    self.pins = pins
  }

  private var loginTask: URLSessionDataTask?
  func login(
    user: String,
    pass: String,
    onSuccess: @escaping () -> Void
  ) {
    loginTask?.cancel()
    
    do {
      loginTask = try api.post(
        path: "/login",
        data: [ "user": user, "pass": pass ]
      ) { (json: Authorisation) in
        print("Authorisation: \(user)")

        self.api.token = json.token
        self.fetchUser(user: user) {
          self.isLoggedIn = true
    
          onSuccess()
        }
      }
    } catch {
      print("Can't login: \(error)")
    }
  }
  
  private var userTask: URLSessionDataTask?
  func fetchUser(
    user: String,
    onSuccess: @escaping () -> Void
  ) {
    userTask?.cancel()
    
    do {
      userTask = try api.get(path: "/\(user)") { (json: User) in
        print("User: \(user)")
        self.user = json
        onSuccess()
      }
    } catch {
      print("Can't fetch users: \(error)")
    }
  }
  
  private var userPinsTask: URLSessionDataTask?
  func fetchUserPins(onSuccess: @escaping () -> Void) {
    userPinsTask?.cancel()
    
    guard let userName = user?.name else {
      print("Please /login first, then fetch user info")
      return
    }
    
    do {
      userPinsTask = try api.get(path: "/\(userName)/bookmarks") { (json: [Pin]) in
        print("Pins: \(json)")
        self.pins = json
        onSuccess()
      }
    } catch {
      print("Can't fetch user pins: \(error)")
    }
  }
}

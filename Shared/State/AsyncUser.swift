//
//  UserData.swift
//  piny
//
//  Created by John Grishin on 14/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftData
import SwiftUI

struct AsyncUserResult {
  let fetchUser = Async<UserDTO>()
  let signUp = Async<Authorization>()
  let login = Async<Authorization>()
  let refreshSession = Async<Authorization>()
  let logout = Async<PinyMessageResponse>()
}

@Observable
class AsyncUser {
  let result = AsyncUserResult()
  let userActor = UserActor(modelContainer: .shared)
  let sessionActor = SessionActor(modelContainer: .shared)

  init(
    _ initialUser: User? = nil,
    initialSession: Session? = nil,
  ) {
    Task {
      if let initialUser = initialUser { await userActor.insert(initialUser) }
      if let initialSession = initialSession { await sessionActor.insert(initialSession) }

      do {
        Piny.api.token = await sessionActor.find()?.token
        try await refreshSession()
      } catch ResponseError.unauthorized {
        deleteAllData()
      } catch {
        Piny.log("Session refresh failed: \(error)", .error)
      }
    }
  }

  private func fetchUser(name: String) async throws -> UserDTO {
    try await result.fetchUser.capture {
      try await Piny.api.get(
        UserDTO.self,
        path: "/\(name)"
      )
    }
  }

  @discardableResult
  func signUp(name: String, pass: String, email: String) async throws -> Authorization {
    try await result.signUp.capture {
      try await Piny.api.post(
        PinyMessageResponse.self,
        path: "/signup",
        json: ["user": name, "pass": pass, "email": email]
      )

      return try await self.login(name: name, pass: pass)
    }
  }

  @discardableResult
  func login(name: String, pass: String) async throws -> Authorization {
    guard let deviceId = await UIDevice.current.identifierForVendor else {
      throw Piny.Error.runtimeError("No device id found")
    }

    let device = await Device(
      id: deviceId,
      description: """
          \(UIDevice.current.model) (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))
        """
    )

    return try await result.login.capture {
      let auth = try await Piny.api.post(
        Authorization.self,
        path: "/login",
        json: Authorization.Payload(
          user: name,
          pass: pass,
          device: device
        )
      )

      Piny.log("Token: \(auth.token)")
      Piny.api.token = auth.token

      let user = try await self.fetchUser(name: name)

      Piny.log("User: \(user)")
      Piny.log("Session: \(auth)")

      do {
        try await sessionActor.sync(
          session: Session(from: auth),
          user: User(from: user)
        )
      } catch {
        Piny.log("Failed to update user/session: \(error)", .error)
        throw error
      }

      return auth
    }
  }

  @discardableResult
  func refreshSession() async throws -> Authorization {
    try await result.refreshSession.capture {
      let auth = try await Piny.api.post(
        Authorization.self,
        path: "/refresh-session",
        json: Optional<Data>.none
      )

      Piny.log("Token: \(auth.token)")
      Piny.api.token = auth.token

      await sessionActor.insert(Session(from: auth))
      return auth
    }
  }

  func logout() async throws {
    try await result.logout.capture {
      do {
        let result = try await Piny.api.post(
          PinyMessageResponse.self,
          path: "/logout",
          json: Optional<Data>.none
        )

        deleteAllData()
        return result
      } catch {
        switch error {
          case ResponseError.unauthorized:
            deleteAllData()
            fallthrough
          default:
            throw error
        }
      }
    }
  }

  func deleteAllData() {
    Piny.api.token = nil
    Piny.storage.container.deleteAllData()
  }
}

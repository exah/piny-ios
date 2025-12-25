//
//  SessionState.swift
//  piny
//
//  Created by John Grishin on 14/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftData
import SwiftUI

struct AsyncSessionResult {
  let signUp = Async<SessionDTO>()
  let login = Async<SessionDTO>()
  let refresh = Async<SessionDTO>()
  let logout = Async<PinyMessageResponse>()
}

@Observable
class SessionState {
  let result = AsyncSessionResult()
  let userActor = UserActor(modelContainer: .shared)
  let sessionActor = SessionActor(modelContainer: .shared)
  let pinActor = PinActor(modelContainer: .shared)
  let tagActor = TagActor(modelContainer: .shared)

  init(
    _ initialUser: UserModel? = nil,
    initialSession: SessionModel? = nil,
  ) {
    Task {
      if let initialUser = initialUser { try await userActor.insert(initialUser) }
      if let initialSession = initialSession { try await sessionActor.insert(initialSession) }

      do {
        try await refresh()
      } catch ResponseError.unauthorized {
        try await clear()
      } catch {
        Piny.log("Session refresh failed: \(error)", .error)
      }
    }
  }

  @discardableResult
  func signUp(name: String, pass: String, email: String) async throws -> SessionDTO {
    try await result.signUp.capture {
      let sessionDTO = try await SessionRequests.signUp(name: name, pass: pass, email: email)
      try await update(sessionDTO, name: name)

      return sessionDTO
    }
  }

  @discardableResult
  func login(name: String, pass: String) async throws -> SessionDTO {
    try await result.login.capture {
      let sessionDTO = try await SessionRequests.login(name: name, pass: pass)
      try await update(sessionDTO, name: name)

      return sessionDTO
    }
  }

  @discardableResult
  func refresh() async throws -> SessionDTO {
    try await result.refresh.capture {
      let sessionDTO = try await SessionRequests.refresh()
      let user = try await userActor.get()

      try await update(sessionDTO, name: user.name)

      return sessionDTO
    }
  }

  @discardableResult
  func logout() async throws -> PinyMessageResponse {
    try await result.logout.capture {
      try await clear()
      return try await SessionRequests.logout()
    }
  }

  private func update(_ sessionDTO: SessionDTO, name: String) async throws {
    Piny.log("Token: \(sessionDTO.token)")

    try await sessionActor.clear()
    try await sessionActor.insert(SessionModel(from: sessionDTO))

    let userDTO = try await UserRequests.get(name: name)

    try await userActor.clear()
    try await userActor.insert(UserModel(from: userDTO))
  }

  private func clear() async throws {
    try await sessionActor.clear()
    try await userActor.clear()
    try await tagActor.clear()
    try await pinActor.clear()
  }
}

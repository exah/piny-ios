//
//  SessionRequests.swift
//  piny
//
//  Created by J. Grishin on 25/12/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import SwiftUI

struct SessionRequests {
  struct SignupPayload: Codable {
    let user: String
    let pass: String
    let email: String
  }

  static func signUp(name: String, pass: String, email: String) async throws -> SessionDTO {
    try await Piny.api.post(
      PinyMessageResponse.self,
      path: "/signup",
      json: SignupPayload(user: name, pass: pass, email: email)
    )

    return try await login(name: name, pass: pass)
  }

  struct LoginPayload: Codable {
    let user: String
    let pass: String
    let device: SessionDevice
  }

  static func login(name: String, pass: String) async throws -> SessionDTO {
    guard let deviceId = await UIDevice.current.identifierForVendor else {
      throw Piny.Error.runtimeError("No device id found")
    }

    let device = await SessionDevice(
      id: deviceId,
      description: """
        \(UIDevice.current.model) (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))
        """
    )

    return try await Piny.api.post(
      SessionDTO.self,
      path: "/login",
      json: LoginPayload(
        user: name,
        pass: pass,
        device: device
      )
    )
  }

  static func refresh() async throws -> SessionDTO {
    try await Piny.api.post(
      SessionDTO.self,
      path: "/refresh-session",
      json: Optional<Data>.none
    )
  }

  static func logout() async throws -> PinyMessageResponse {
    try await Piny.api.post(
      PinyMessageResponse.self,
      path: "/logout",
      json: Optional<Data>.none
    )
  }
}

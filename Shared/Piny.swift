//
//  Piny.swift
//  piny
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import SwiftData

struct Piny {
  static let api = API(baseURL: Bundle.main.object(forInfoDictionaryKey: "API_URL") as! String)
  static var storage = Storage(
    "piny",
    schema: Schema([
      PinModel.self,
      LinkModel.self,
      TagModel.self,
      UserModel.self,
      SessionModel.self,
    ])
  )

  static func log<T>(_ input: T, _ level: LogLevel = LogLevel.info) {
    print("🌲 [\(level)] \(Date()): \(input)")
  }

  enum Error: Swift.Error {
    case runtimeError(String)
  }

  enum LogLevel: String {
    case info, warn, error
  }
}

extension ModelContainer {
  static var shared: ModelContainer {
    Piny.storage.container
  }
}

//
//  Piny.swift
//  piny
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import Sentry
import SwiftData

enum Piny {
  static let api = API(baseURL: config.apiURL)
  static let config = Config()
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

  struct Config {
    let apiURL: String
    let sentryDSN: String?

    init() {
      let apiURL = Bundle.main.object(forInfoDictionaryKey: "API_URL") as! String
      let sentryDSN = Bundle.main.object(forInfoDictionaryKey: "SENTRY_DSN_URL") as? String

      self.apiURL = apiURL
      self.sentryDSN = sentryDSN == "https://" ? nil : sentryDSN
    }
  }

  static func Sentry() {
    guard let dsn = config.sentryDSN else {
      Piny.log("Sentry not setup for the environment")
      return
    }

    SentrySDK.start { options in
      options.dsn = dsn
    }
  }
}

extension ModelContainer {
  static var shared: ModelContainer {
    Piny.storage.container
  }
}

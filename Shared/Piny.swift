//
//  Piny.swift
//  piny
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation

struct Piny {
  static var api = API(baseURL: "https://dev.piny.link")
  static var storage = Storage("piny", groupURL: groupURL)

  static let groupID = "group.com.exah.piny"
  static let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)

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

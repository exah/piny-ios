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

  static let groupID = "group.872a0eea-5eee-42ad-8633-a43cddf6b675.piny"
  static let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)

  enum Error: Swift.Error {
    case runtimeError(String)
  }
}

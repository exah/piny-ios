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

  static func saveContext() {
    let context = storage.container.viewContext

    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }

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

//
//  Log.swift
//  piny
//
//  Created by John Grishin on 22/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation

enum LogLevel: String {
  case info, warn, error
}

func log<T>(_ input: T, level: LogLevel = .info) {
  print("[\(level)] \(Date()): \(input)")
}

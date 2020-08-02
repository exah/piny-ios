//
//  JSON.swift
//  piny
//
//  Created by John Grishin on 02/08/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation

struct JSON {
  private let formatter: DateFormatter
  private let decoder: JSONDecoder

  init() {
    formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

    decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(formatter)
  }

  func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
    try decoder.decode(T.self, from: data)
  }
}

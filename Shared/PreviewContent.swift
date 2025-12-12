//
//  PreviewContent.swift
//  piny
//
//  Created by John Grishin on 02/08/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation

private let PREVIEW_USER: UserDTO = load("preview-user.json")
private let PREVIEW_PINS: [PinDTO] = load("preview-pins.json")
private let PREVIEW_TAGS: [PinTagDTO] = load("preview-tags.json")

private func load<T: Decodable>(_ filename: String) -> T {
  let data: Data

  guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
  else {
    fatalError("Couldn't find \(filename) in main bundle.")
  }

  do {
    data = try Data(contentsOf: file)
  } catch {
    fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
  }

  do {
    return try JSON().decode(T.self, from: data)
  } catch {
    fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
  }
}

struct PreviewContent {
  static let user: User = User(from: PREVIEW_USER)
  static let tags: [PinTag] = PREVIEW_TAGS.map { PinTag(from: $0) }
  static let pins: [Pin] = PREVIEW_PINS.map { Pin(from: $0, tags: tags) }
}

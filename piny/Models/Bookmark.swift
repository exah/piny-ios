//
//  Bookmark.swift
//  piny
//
//  Created by John Grishin on 15/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation

struct Pin: Hashable, Codable, Identifiable {
  var id: UUID
  var title: String?
  var description: String?
  var privacy: PrivacyType
  var link: Link
  var tags: [Tag]
}

struct Link: Hashable, Codable, Identifiable {
  var id: UUID
  var url: String
}

struct Tag: Hashable, Codable, Identifiable {
  var id: UUID
  var name: String
}

enum PrivacyType: String, Codable {
  case Public = "public"
}


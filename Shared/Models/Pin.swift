//
//  Pin.swift
//  piny
//
//  Created by John Grishin on 15/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import CoreData

struct Pin: Hashable, Codable, Identifiable {
  enum State: String, Codable {
    case ACTIVE = "active"
    case REMOVED = "removed"
  }

  enum Privacy: String, Codable {
    case PUBLIC = "public"
    case PRIVATE = "private"
  }

  var id: UUID
  var title: String?
  var description: String?
  var state: Pin.State
  var privacy: Pin.Privacy
  var link: PinLink
  var tags: [PinTag]
  var createdAt: Date
  var updatedAt: Date
}

extension Pin: Persistable {
  static func fromObject(_ object: DBPin) -> Pin {
    Pin(
      id: object.id,
      title: object.title,
      description: object.desc,
      state: Pin.State(rawValue: object.state)!,
      privacy: Pin.Privacy(rawValue: object.privacy)!,
      link: PinLink.fromObject(object.link),
      tags: Array(object.tags).map { tag in
        PinTag.fromObject(tag)
      },
      createdAt: object.createdAt,
      updatedAt: object.updatedAt
    )
  }

  func toObject(in context: NSManagedObjectContext) -> DBPin {
    let entity = DBPin.create(in: context)

    entity.id = id
    entity.title = title
    entity.desc = description
    entity.state = state.rawValue
    entity.privacy = privacy.rawValue
    entity.link = link.toObject(in: context)
    entity.tags = Set(tags.map { tag in
      tag.toObject(in: context)
    })
    entity.createdAt = createdAt
    entity.updatedAt = updatedAt

    return entity
  }
}

class DBPin: NSManagedObject {
  @NSManaged var id: UUID
  @NSManaged var title: String?
  @NSManaged var desc: String?
  @NSManaged var privacy: String
  @NSManaged var state: String
  @NSManaged var link: DBPinLink
  @NSManaged var tags: Set<DBPinTag>
  @NSManaged var createdAt: Date
  @NSManaged var updatedAt: Date
}

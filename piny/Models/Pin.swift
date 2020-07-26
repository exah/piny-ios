//
//  Pin.swift
//  piny
//
//  Created by John Grishin on 15/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import CoreData

enum PrivacyType: String, Codable {
  case Public = "public"
}

struct Pin: Hashable, Codable, Identifiable {
  var id: UUID
  var title: String?
  var description: String?
  var privacy: PrivacyType
  var link: PinLink
  var tags: [PinTag]
}

extension Pin: Persistable {
  static func fromObject(_ object: DBPin) -> Pin {
    Pin(
      id: object.id,
      title: object.title,
      description: object.desc,
      privacy: PrivacyType(rawValue: object.privacy)!,
      link: PinLink.fromObject(object.link),
      tags: Array(object.tags).map { tag in
        PinTag.fromObject(tag)
      }
    )
  }

  func toObject(in context: NSManagedObjectContext) -> DBPin {
    let entity = DBPin.create(in: context)

    entity.id = id
    entity.title = title
    entity.desc = description
    entity.privacy = privacy.rawValue
    entity.link = link.toObject(in: context)
    entity.tags = Set(tags.map { tag in
      tag.toObject(in: context)
    })

    return entity
  }
}

class DBPin: NSManagedObject {
  @NSManaged var id: UUID
  @NSManaged var title: String?
  @NSManaged var desc: String?
  @NSManaged var privacy: String
  @NSManaged var link: DBPinLink
  @NSManaged var tags: Set<DBPinTag>
}

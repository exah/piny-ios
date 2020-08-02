//
//  PinTag.swift
//  piny
//
//  Created by John Grishin on 21/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import CoreData

struct PinTag: Hashable, Codable, Identifiable {
  var id: UUID
  var name: String
}

extension PinTag: Persistable {
  static func fromObject(_ object: DBPinTag) -> PinTag {
    PinTag(
      id: object.id,
      name: object.name
    )
  }

  func toObject(in context: NSManagedObjectContext) -> DBPinTag {
    let entity = DBPinTag.create(in: context)
    entity.id = id
    entity.name = name
    return entity
  }
}

class DBPinTag: NSManagedObject {
  @NSManaged var id: UUID
  @NSManaged var name: String
}

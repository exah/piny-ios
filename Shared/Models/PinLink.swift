//
//  PinLink.swift
//  piny
//
//  Created by John Grishin on 21/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import CoreData

struct PinLink: Hashable, Codable, Identifiable {
  var id: UUID
  var url: URL
}

extension PinLink: Persistable {
  static func fromObject(_ object: DBPinLink) -> PinLink {
    PinLink(
      id: object.id,
      url: object.url
    )
  }

  func toObject(in context: NSManagedObjectContext) -> DBPinLink {
    let entity = DBPinLink.create(in: context)
    entity.id = id
    entity.url = url
    return entity
  }
}

class DBPinLink: NSManagedObject {
  @NSManaged var id: UUID
  @NSManaged var url: URL
}

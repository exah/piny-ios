//
//  User.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import CoreData

struct User: Identifiable, Codable {
  let id: UUID
  let name: String
  let email: String
  var token: String?
}

extension User: Persistable {
  static func fromObject(_ object: DBUser) -> User {
    User(
      id: object.id,
      name: object.name,
      email: object.email,
      token: object.token
    )
  }

  func toObject(in context: NSManagedObjectContext) -> DBUser {
    let entity = DBUser.create(in: context)
    entity.id = id
    entity.name = name
    entity.email = email
    entity.token = token
    return entity
  }
}

class DBUser: NSManagedObject {
  @NSManaged var id: UUID
  @NSManaged var name: String
  @NSManaged var email: String
  @NSManaged var token: String?
}

//
//  Persistable.swift
//  piny
//
//  Created by John Grishin on 21/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import CoreData

protocol Persistable {
  associatedtype ObjectType: NSManagedObject

  static func fromObject(_ object: ObjectType) -> Self

  @discardableResult
  func toObject(in context: NSManagedObjectContext) -> ObjectType
}

extension Persistable {
  static func fromObject(_ object: ObjectType?) -> Self? {
    guard let object = object else {
      return nil
    }

    return self.fromObject(object)
  }
}

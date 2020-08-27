//
//  Storage.swift
//  piny
//
//  Created by John Grishin on 21/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import CoreData

private
extension Identifiable {
  var identifier: String {
    if let uuid = id as? UUID {
      return uuid.uuidString
    }

    if let int = id as? Int {
      return int.description
    }

    return "\(id.hashValue)"
  }
}

private
extension NSManagedObjectContext {
  func applyStackChangesAndWait(_ block: @escaping () -> Void) {
    performAndWait {
      block()
      self.saveContextsStack()
    }
  }

  func saveContextsStack() {
    var contextToSave: NSManagedObjectContext? = self

    while let currentContext = contextToSave {
      currentContext.performAndWait {
        do {
          try currentContext.save()
        } catch {
          Piny.log("context saving failure: \(error)")
        }
      }

      contextToSave = currentContext.parent
    }
  }
}

extension NSManagedObject {
  static func getName() -> String {
    var name = String(describing: self).components(separatedBy: ".").last ?? ""

    if name.hasPrefix("DB") {
      let index = name.index(name.startIndex, offsetBy: 2)
      name = String(name[index...])
    }

    return name
  }

  static func create(in context: NSManagedObjectContext) -> Self {
    guard let object = NSEntityDescription.entity(
      forEntityName: self.getName(),
      in: context
    ) else {
      fatalError("Entity not found: \(self)")
    }

    return self.init(entity: object, insertInto: context)
  }
}

final class Storage {
  let container: NSPersistentContainer

  var currentContext: NSManagedObjectContext {
    if Thread.isMainThread {
      return self.container.viewContext
    } else {
      return self.backgroundContext
    }
  }

  private lazy var backgroundContext: NSManagedObjectContext = {
    return self.container.newBackgroundContext()
  }()

  init(_ name: String, groupURL: URL? = nil) {
    container = NSPersistentContainer(name: name)

    if let groupURL = groupURL {
      let storeURL = groupURL.appendingPathComponent("\(name).sqlite")
      let storeDescription = NSPersistentStoreDescription(url: storeURL)

      container.persistentStoreDescriptions = [storeDescription]
    }

    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
  }

  func fetch<T: Identifiable & Persistable>(
    _ type: T.Type,
    predicate: NSPredicate? = nil,
    sortDescriptors: [NSSortDescriptor]? = nil,
    limit: Int = 0,
    in specificContext: NSManagedObjectContext? = nil
  ) -> [T] {
    let context = specificContext ?? currentContext
    let request = NSFetchRequest<T.ObjectType>(entityName: T.ObjectType.getName())
    var result: [T] = []

    request.predicate = predicate
    request.sortDescriptors = sortDescriptors
    request.fetchLimit = limit

    context.performAndWait {
      do {
        let fetched = try context.fetch(request)
        result = fetched.map(T.fromObject)
      } catch {
        let metadata = "entity: \(T.ObjectType.getName()), "
          + "predicate: \(predicate?.predicateFormat ?? ""), "
          + "sortDescriptorsCount: \(sortDescriptors?.count ?? 0),"
          + "error: \(error)"

        Piny.log("Core Data Fetch Failed \(metadata)")
      }
    }

    return result
  }

  func fetch<T: Identifiable & Persistable>(
    _ type: T.Type,
    identifier: String,
    in specificContext: NSManagedObjectContext? = nil
  ) -> T? {
    let context = specificContext ?? currentContext
    let request = NSFetchRequest<T.ObjectType>(entityName: T.ObjectType.getName())
    var result: T? = nil

    request.predicate = NSPredicate(format: "id == %@", identifier)

    context.performAndWait {
      do {
        let fetched = try context.fetch(request)
        result = fetched.map(T.fromObject).first
      } catch {
        Piny.log("Core Data Fetch By ID Failed entity: \(T.ObjectType.getName()), identifier: \(identifier), error: \(error)")
      }
    }

    return result
  }

  func save<T: Identifiable & Persistable>(
    _ objects: [T],
    batchSize: Int = 100,
    in specificContext: NSManagedObjectContext? = nil
  ) {
    let context = specificContext ?? currentContext
    let batches = batch(objects, size: batchSize)

    for var batch in batches {
      let objectsIds = batch.map({ $0.identifier })
      let predicate = NSPredicate(format: "id IN %@", objectsIds)
      let copy = batch

      self.remove(T.self, predicate: predicate, in: context)

      context.applyStackChangesAndWait {
        _ = copy.map({ $0.toObject(in: context) })
      }

      batch = self.fetch(T.self, predicate: predicate, in: context)

      if copy.count != batch.count {
        Piny.log("Core Data Fetch after Save Failed entity: \(T.ObjectType.getName()), identifiers: \(objectsIds.joined(separator: ","))")
      }
    }
  }

  func save<T: Identifiable & Persistable>(
    _ object: T,
    in specificContext: NSManagedObjectContext? = nil
  ) {
    let context = specificContext ?? currentContext

    let predicate = NSPredicate(format: "id == %@", object.identifier)
    let objectCopy = object

    self.remove(T.self, predicate: predicate, in: context)

    context.applyStackChangesAndWait {
      objectCopy.toObject(in: context)
    }

    if self.fetch(T.self, identifier: object.identifier) == nil {
      Piny.log("Core Data Fetch after Save Failed entity: \(T.ObjectType.getName()), identifier: \(object.identifier)")
    }
  }

  func remove<T: Identifiable & Persistable>(
    _ objects: [T],
    batchSize: Int = 100,
    in specificContext: NSManagedObjectContext? = nil
  ) {
    let context = specificContext ?? currentContext
    let batches = batch(objects, size: batchSize)

    for item in batches {
      let identifiers = item.map({ $0.identifier })
      let predicate = NSPredicate(format: "id IN %@", identifiers)
      self.remove(T.self, predicate: predicate, in: context)
    }
  }

  func remove<T: Identifiable & Persistable>(
    _ object: T,
    in specificContext: NSManagedObjectContext? = nil
  ) {
    remove(T.self, identifier: object.identifier, in: specificContext)
  }

  func remove<T: Identifiable & Persistable>(
    _ type: T.Type,
    identifier: String,
    in specificContext: NSManagedObjectContext? = nil
  ) {
    self.remove(type, predicate: NSPredicate(format: "id == %@", identifier), in: specificContext)
  }

  func remove<T: Identifiable & Persistable>(
    _ type: T.Type,
    predicate: NSPredicate? = nil,
    in specificContext: NSManagedObjectContext? = nil
  ) {
    let context = specificContext ?? currentContext
    let request = NSFetchRequest<T.ObjectType>(entityName: T.ObjectType.getName())
    var fetched: [T.ObjectType] = []

    request.predicate = predicate
    request.includesPropertyValues = false

    context.performAndWait {
      do {
        fetched = try context.fetch(request)
      } catch {
        let metadata = "entity: \(T.ObjectType.getName()), "
          + "predicate: \(predicate?.predicateFormat ?? ""), "
          + "error: \(error)"

        Piny.log("Core Data Fetch on Remove Failed \(metadata)")
      }
    }

    context.applyStackChangesAndWait {
      fetched.forEach(context.delete)
    }
  }

  func saveContext() {
    if container.viewContext.hasChanges {
      do {
        try container.viewContext.save()
      } catch {
        if let error = error as NSError? {
          fatalError("Unresolved error \(error), \(error.userInfo)")
        }
      }
    }
  }

  private func batch<T>(_ input: [T], size: Int) -> [[T]] {
    var result: [[T]] = []
    var accumulator: [T] = []

    for item in input {
      accumulator.append(item)

      if accumulator.count == size {
        result.append(accumulator)
        accumulator = []
      }
    }

    if !accumulator.isEmpty {
      result.append(accumulator)
    }

    return result
  }
}

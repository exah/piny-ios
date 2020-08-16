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
  func applyStackChangesAndWait(_ completion: @escaping () -> Void) {
    performAndWait {
      completion()
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

struct Storage {
  let container: NSPersistentContainer
  var context: NSManagedObjectContext {
    return self.container.viewContext
  }

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
}

extension Storage {
  func fetch<T: Identifiable & Persistable>(
    _ type: T.Type,
    predicate: NSPredicate? = nil,
    sortDescriptors: [NSSortDescriptor]? = nil,
    limit: Int = 0
  ) -> [T] {
    let context = contextForCurrentThread()
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

  func fetch<T: Identifiable & Persistable>(_ type: T.Type, identifier: String) -> T? {
    let context = contextForCurrentThread()
    let request = NSFetchRequest<T.ObjectType>(entityName: T.ObjectType.getName())
    var result: T? = nil

    request.predicate = NSPredicate(format: "identifier == %@", identifier)

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

  @discardableResult func save<T: Identifiable & Persistable>(_ objects: [T], batchSize: Int = 100) -> [T] {
    let context = contextForCurrentThread()
    let batches = batch(objects, size: batchSize)

    for var item in batches {
      let objectsIds = item.map({ $0.identifier })
      let predicate = NSPredicate(format: "identifier IN %@", objectsIds)
      let copy = item

      self.remove(T.self, predicate: predicate, in: context)
      context.applyStackChangesAndWait {
        _ = copy.map({ $0.toObject(in: context) })
      }

      item = self.fetch(T.self, predicate: predicate)
      if copy.count != item.count {
        Piny.log("Core Data Fetch after Save Failed entity: \(T.ObjectType.getName()), identifiers: \(objectsIds.joined(separator: ","))")
      }
    }

    return Array(batches.joined())
  }

  @discardableResult func save<T: Identifiable & Persistable>(_ object: T) -> T {
    let context = contextForCurrentThread()

    Piny.log("identifier \(object.identifier)")

    let predicate = NSPredicate(format: "identifier == %@", object.identifier)
    let objectCopy = object

    self.remove(T.self, predicate: predicate, in: context)
    context.applyStackChangesAndWait {
      objectCopy.toObject(in: context)
    }

    if let cachedObject = self.fetch(T.self, identifier: object.identifier) {
      return cachedObject
    } else {
      Piny.log("Core Data Fetch after Save Failed entity: \(T.ObjectType.getName()), identifier: \(object.identifier)")
      return object
    }
  }

  func remove<T: Identifiable & Persistable>(_ objects: [T], batchSize: Int = 100) {
    let context = contextForCurrentThread()
    let batches = batch(objects, size: batchSize)

    for item in batches {
      let identifiers = item.map({ $0.identifier })
      let predicate = NSPredicate(format: "identifier IN %@", identifiers)
      self.remove(T.self, predicate: predicate, in: context)
    }
  }

  func remove<T: Identifiable & Persistable>(_ object: T) {
    remove(T.self, identifier: object.identifier)
  }

  func remove<T: Identifiable & Persistable>(_ type: T.Type, identifier: String) {
    self.remove(type, predicate: NSPredicate(format: "identifier == %@", identifier))
  }

  func remove<T: Identifiable & Persistable>(_ type: T.Type, predicate: NSPredicate? = nil, in specificContext: NSManagedObjectContext? = nil) {
    let context = specificContext ?? contextForCurrentThread()
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

  private func contextForCurrentThread() -> NSManagedObjectContext {
    if Thread.isMainThread {
      return self.container.viewContext
    } else {
      return self.container.newBackgroundContext()
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

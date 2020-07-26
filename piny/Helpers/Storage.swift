//
//  Storage.swift
//  piny
//
//  Created by John Grishin on 21/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import CoreData

private
enum Constants {
  static let saveBatchSize = 100
  static let removeBatchSize = 100
}

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
          print("context saving failure: \(error)")
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

  init(_ name: String) {
    container = NSPersistentContainer(name: name)

    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
  }
}

extension Storage {

  func fetch<Model: Identifiable & Persistable>(
    _ modelType: Model.Type,
    predicate: NSPredicate? = nil,
    sortDescriptors: [NSSortDescriptor]? = nil,
    limit: Int = 0
  ) -> [Model] {

    let context = contextForCurrentThread()
    let request = NSFetchRequest<Model.ObjectType>(entityName: Model.ObjectType.getName())
    request.predicate = predicate
    request.sortDescriptors = sortDescriptors
    request.fetchLimit = limit

    var result: [Model] = []
    context.performAndWait {
      do {
        let fetched = try context.fetch(request)
        result = fetched.map(Model.fromObject)
      } catch {
        let metadata = "entity: \(Model.ObjectType.getName()), "
          + "predicate: \(predicate?.predicateFormat ?? ""), "
          + "sortDescriptorsCount: \(sortDescriptors?.count ?? 0),"
          + "error: \(error)"

        print("Core Data Fetch Failed \(metadata)")
      }
    }
    return result
  }

  func fetch<Model: Identifiable & Persistable>(_ modelType: Model.Type, identifier: String) -> Model? {
    let context = contextForCurrentThread()
    let request = NSFetchRequest<Model.ObjectType>(entityName: Model.ObjectType.getName())
    request.predicate = NSPredicate(format: "identifier == %@", identifier)

    var result: Model? = nil
    context.performAndWait {
      do {
        let fetched = try context.fetch(request)
        result = fetched.map(Model.fromObject).first
      } catch {
        print("Core Data Fetch By ID Failed entity: \(Model.ObjectType.getName()), identifier: \(identifier), error: \(error)")
      }
    }
    return result
  }

  func save<Model: Identifiable & Persistable>(_ objects: inout [Model]) {
    let context = contextForCurrentThread()
    let batches = batch(objects, size: Constants.saveBatchSize)

    for var item in batches {
      let objectsIds = item.map({ $0.identifier })
      let predicate = NSPredicate(format: "identifier IN %@", objectsIds)
      let itemCopy = item

      self.remove(Model.self, predicate: predicate, in: context)
      context.applyStackChangesAndWait {
        _ = itemCopy.map({ $0.toObject(in: context) })
      }

      item = self.fetch(Model.self, predicate: predicate)
      if itemCopy.count != item.count {
        print("Core Data Fetch after Save Failed entity: \(Model.ObjectType.getName()), identifiers: \(objectsIds.joined(separator: ","))")
      }
    }
  }

  func save<Model: Identifiable & Persistable>(_ object: inout Model) {
    let context = contextForCurrentThread()

    log("identifier \(object.identifier)")

    let predicate = NSPredicate(format: "identifier == %@", object.identifier)
    let objectCopy = object

    self.remove(Model.self, predicate: predicate, in: context)
    context.applyStackChangesAndWait {
      objectCopy.toObject(in: context)
    }

    if let cachedObject = self.fetch(Model.self, identifier: object.identifier) {
      object = cachedObject
    } else {
      print("Core Data Fetch after Save Failed entity: \(Model.ObjectType.getName()), identifier: \(object.identifier)")
    }
  }

  func remove<Model: Identifiable & Persistable>(_ objects: [Model]) {
    let context = contextForCurrentThread()
    let batches = batch(objects, size: Constants.removeBatchSize)

    for item in batches {
      let identifiers = item.map({ $0.identifier })
      let predicate = NSPredicate(format: "identifier IN %@", identifiers)
      self.remove(Model.self, predicate: predicate, in: context)
    }
  }

  func remove<Model: Identifiable & Persistable>(_ object: Model) {
    remove(Model.self, identifier: object.identifier)
  }

  func remove<Model: Identifiable & Persistable>(_ modelType: Model.Type, identifier: String) {
    self.remove(modelType, predicate: NSPredicate(format: "identifier == %@", identifier))
  }

  func remove<Model: Identifiable & Persistable>(_ modelType: Model.Type, predicate: NSPredicate? = nil, in specificContext: NSManagedObjectContext? = nil) {
    let context = specificContext ?? contextForCurrentThread()
    let request = NSFetchRequest<Model.ObjectType>(entityName: Model.ObjectType.getName())
    request.predicate = predicate
    request.includesPropertyValues = false

    var fetched: [Model.ObjectType] = []
    context.performAndWait {
      do {
        fetched = try context.fetch(request)
      } catch {
        let metadata = "entity: \(Model.ObjectType.getName()), "
          + "predicate: \(predicate?.predicateFormat ?? ""), "
          + "error: \(error)"

        print("Core Data Fetch on Remove Failed \(metadata)")
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

import CoreData

extension NSPersistentContainer {
    static func load(modelName: String, model: NSManagedObjectModel, url: URL) throws -> NSPersistentContainer {
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: url)
        container.persistentStoreDescriptions = [description]
        var loadError: Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw $0 }

        return container
    }
}

extension NSManagedObjectModel {
    static func with(name: String, bundle: Bundle) -> NSManagedObjectModel? {
        bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap({ NSManagedObjectModel(contentsOf: $0) })
    }
}

import CoreData

extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Error)
    }

    static func load(modelName: String, storeURL: URL, bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: modelName, bundle: bundle) else {
            throw LoadingError.modelNotFound
        }

        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [description]
        var loadError: Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }

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

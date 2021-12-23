import XCTest
import EssentialFeed

import CoreData

class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: String?
    @NSManaged var cache: ManagedCache
}

class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer

    init() throws {
        self.container = try NSPersistentContainer.load(modelName: "FeedStore", bundle: Bundle(for: Self.self))
    }

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}

extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Error)
    }

    static func load(modelName: String, bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: modelName, bundle: bundle) else {
            throw LoadingError.modelNotFound
        }

        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
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

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
//        let sut = makeSUT()

//        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {

    }

    func test_insert_deliversNoErrorOnEmptyCache() {

    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {

    }

    func test_insert_overridesPreviouslyInsertedCacheValues() {

    }

    func test_delete_deliversNoErrorOnEmptyCache() {

    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {

    }

    func test_delete_deliversNoErrorOnNonEmptyCache() {

    }

    func test_delete_emptiesPreviouslyInsertedCache() {

    }

    func test_storeSideEffects_runSerially() {

    }

    // MARK: - HELPER

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = try! CoreDataFeedStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}

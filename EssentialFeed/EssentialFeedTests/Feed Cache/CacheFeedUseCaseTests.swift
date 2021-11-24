//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Rodrigo Carvalho on 24/11/21.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date

    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed() { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([FeedItem], Date)
    }

    private(set) var receivedMessages = [ReceivedMessage]()

    var deletionCompletions = [DeletionCompletion]()
    var insertionCompletions = [InsertionCompletion]()

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }

    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items, timestamp))
    }
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (store, _) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }


    func test_save_requestsCacheDeletion() {
        let (store, sut) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items) { _ in }

        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (store, sut) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()

        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }

    func test_save_requestsCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (store, sut) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
    }

    func test_save_failsOnDeletionError() {
        let (store, sut) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        let exp = expectation(description: "Waits for save completion")

        var receivedError: Error?
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }

        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, deletionError)
    }

    func test_save_failsOnInsertionError() {
        let (store, sut) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let insertionError = anyNSError()
        let exp = expectation(description: "Waits for save completion")

        var receivedError: Error?
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }

        store.completeDeletionSuccessfully()
        store.completeInsertion(with: insertionError)
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, insertionError)
    }

    // MARK: - HELPER

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (FeedStore, LocalFeedLoader) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (store, sut)
    }

    private func uniqueItem() -> FeedItem {
        .init(id: .init(), description: "any", location: "any", imageURL: anyURL())
    }

    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }

    private func anyNSError() -> NSError {
        NSError(domain: "any domain", code: 400, userInfo: nil)
    }
}

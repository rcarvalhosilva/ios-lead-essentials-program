//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Rodrigo Carvalho on 30/11/21.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (store, _) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    // MARK: - HELPER

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (FeedStoreSpy, LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (store, sut)
    }

    private class FeedStoreSpy: FeedStore {
        enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case insert([LocalFeedImage], Date)
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

        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletions[index](nil)
        }

        func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletions.append(completion)
            receivedMessages.append(.insert(feed, timestamp))
        }
    }
}

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

    func test_load_requestsRetrievalFromTheStore() {
        let (store, sut) = makeSUT()

        sut.load() { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_failsOnRetrievalError() {
        let (store, sut) = makeSUT()
        let retrievalError = anyNSError()

        let exp = expectation(description: "Wait for load completion")

        var receivedError: Error?
        sut.load() { result in
            switch result {
            case .failure(let error):
                receivedError = error
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            exp.fulfill()
        }

        store.completeRetrieval(with: retrievalError)

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, retrievalError)
    }

    func test_load_deliversNoImagesOnEmptyCache() {
        let (store, sut) = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")

        var receivedImages: [FeedImage]?
        sut.load() { result in
            switch result {
            case let .success(images):
                receivedImages = images
            default:
                XCTFail("Expected success, got \(result) instead")
            }
            exp.fulfill()
        }

        store.completeRetrievalWithEmptyCache()

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedImages, [])
    }

    // MARK: - HELPER

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (FeedStoreSpy, LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (store, sut)
    }

    private func anyNSError() -> NSError {
        NSError(domain: "any domain", code: 400, userInfo: nil)
    }
}

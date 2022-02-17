import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>

    func retrive(dataForURL url: URL, completion: @escaping (Result) -> Void)
}

final class LocalFeedImageLoader {
    struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }

    enum Error: Swift.Error {
        case failed
        case notFound
    }

    private let store: FeedImageDataStore

    init(store: FeedImageDataStore) {
        self.store = store
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrive(dataForURL: url) { result in
            let result: FeedImageDataLoader.Result = result
                .mapError { _ in Error.failed }
                .flatMap { _ in .failure(Error.notFound) }
            completion(result)
        }

        return Task()
    }
}

class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    func test_loadImageData_requestsStoreDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()

        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }

    func test_loadImageData_failsOnRetrievalError() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: failed()) {
            store.completeRetrieval(with: anyNSError())
        }
    }

    func test_loadImageData_deliversNotFoundErrorOnEmptyCache() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: notFound()) {
            store.completeWith(data: .none)
        }
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }

    private func expect(
        _ sut: LocalFeedImageLoader,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError as LocalFeedImageLoader.Error), .failure(expectedError as LocalFeedImageLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    private func failed() -> FeedImageDataLoader.Result {
        .failure(LocalFeedImageLoader.Error.failed)
    }

    private func notFound() -> FeedImageDataLoader.Result {
        .failure(LocalFeedImageLoader.Error.notFound)
    }

    private final class StoreSpy: FeedImageDataStore {
        enum Messages: Equatable {
            case retrieve(dataFor: URL)
        }

        private(set) var receivedMessages = [Messages]()
        private(set) var retrievalCompletions = [(FeedImageDataStore.Result) -> Void]()

        func retrive(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
            receivedMessages.append(.retrieve(dataFor: url))
            retrievalCompletions.append(completion)
        }

        func completeRetrieval(with error: Error, at index: Int = 0) {
            retrievalCompletions[index](.failure(error))
        }

        func completeWith(data: Data?, at index: Int = 0) {
            retrievalCompletions[index](.success(data))
        }
    }
}

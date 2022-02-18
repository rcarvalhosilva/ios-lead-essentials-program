import XCTest
import EssentialFeed

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
            store.completeRetrieval(with: .none)
        }
    }

    func test_loadImageData_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let foundData = anyData()

        expect(sut, toCompleteWith: .success(foundData)) {
            store.completeRetrieval(with: foundData)
        }
    }

    func test_loadImageData_doesNotDeliverResultAfterCancellingTask() {
        let (sut, store) = makeSUT()
        let foundData = anyData()

        var receivedResult = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { receivedResult.append($0) }
        task.cancel()

        store.completeRetrieval(with: foundData)
        store.completeRetrieval(with: .none)
        store.completeRetrieval(with: anyNSError())

        XCTAssertTrue(receivedResult.isEmpty, "Expected no received results after cancelling task")
    }

    func test_loadImageData_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = StoreSpy()
        var sut: LocalFeedImageLoader? = LocalFeedImageLoader(store: store)

        var receivedResult = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) { receivedResult.append($0) }

        sut = nil

        store.completeRetrieval(with: anyData())

        XCTAssertTrue(receivedResult.isEmpty, "Expected no received results after SUT has been deallocated")
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

        func completeRetrieval(with data: Data?, at index: Int = 0) {
            retrievalCompletions[index](.success(data))
        }

        func insert(data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        }
    }
}

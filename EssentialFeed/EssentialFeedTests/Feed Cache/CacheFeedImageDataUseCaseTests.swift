import EssentialFeed
import XCTest

class CacheFeedImageDataUseCaseTests: XCTestCase {

    func test_saveImageDataForURL_requestsImageDataInsertionForUrl() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        sut.save(data, for: url) { _ in }

        XCTAssertEqual(client.receivedMessages, [.insert(data: data, for: url)])
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }

    private final class StoreSpy: FeedImageDataStore {
        enum Messages: Equatable {
            case retrieve(dataFor: URL)
            case insert(data: Data, for: URL)
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
            receivedMessages.append(.insert(data: data, for: url))
        }
    }
}

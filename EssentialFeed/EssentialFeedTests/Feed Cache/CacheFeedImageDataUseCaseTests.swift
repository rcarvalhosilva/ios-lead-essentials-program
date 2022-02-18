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
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
}

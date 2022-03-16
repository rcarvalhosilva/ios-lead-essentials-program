import EssentialFeed
import EssentialFeedCache
import XCTest

class CacheFeedImageDataUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    func test_saveImageDataForURL_requestsImageDataInsertionForUrl() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        sut.save(data, for: url) { _ in }

        XCTAssertEqual(client.receivedMessages, [.insert(data: data, for: url)])
    }

    func test_saveImageDataForURL_failsOnInsertionError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failed()) {
            client.completeInsertion(with: anyNSError())
        }
    }

    func test_saveImageDataForURL_succeedsOnSuccessfulInsertion() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: success()) {
            client.completeInsertionWithSuccess()
        }
    }

    func test_saveImageDataForURL_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)

        var receivedResults = [LocalFeedImageDataLoader.SaveResult]()
        sut?.save(anyData(), for: anyURL()) { receivedResults.append($0) }

        sut = nil
        store.completeInsertionWithSuccess()

        XCTAssertTrue(receivedResults.isEmpty, "Expected no received results after instance has been deallocated")
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }

    private func failed() -> LocalFeedImageDataLoader.SaveResult {
        .failure(LocalFeedImageDataLoader.SaveError.failed)
    }

    private func success() -> LocalFeedImageDataLoader.SaveResult {
        .success(())
    }

    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toCompleteWith expectedResult: LocalFeedImageDataLoader.SaveResult,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let url = anyURL()
        let data = anyData()

        let exp = expectation(description: "Wait for save completion")
        sut.save(data, for: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError as LocalFeedImageDataLoader.SaveError), .failure(expectedError as LocalFeedImageDataLoader.SaveError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case (.success, .success):
                break
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }
}

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    func retrive(dataForURL url: URL)
}

final class LocalFeedImageLoader {
    struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }

    private let store: FeedImageDataStore

    init(store: FeedImageDataStore) {
        self.store = store
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrive(dataForURL: url)
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
        }

        private(set) var receivedMessages = [Messages]()

        func retrive(dataForURL url: URL) {
            receivedMessages.append(.retrieve(dataFor: url))
        }
    }
}

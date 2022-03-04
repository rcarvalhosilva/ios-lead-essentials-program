import XCTest
import EssentialFeed

protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Swift.Error>

    func save(_ data: Data, for url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void)
}

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache

    init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { data in
                self?.cache.save(data, for: url) { _ in }
                return data
            })
        }
    }
}

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {

    func test_init_doesNotLoadImageData() {
        let (_, loader) = makeSUT()

        XCTAssertTrue(loader.loadedURLs.isEmpty)
    }

    func test_loadImageData_loadsFromLoader() {
        let url = anyURL()
        let (sut, loader) = makeSUT()

        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(loader.loadedURLs, [url])
    }

    func test_cancelLoadImageData_cancelsLoaderTask() {
        let url = anyURL()
        let (sut, loader) = makeSUT()

        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()

        XCTAssertEqual(loader.cancelledURLs, [url])
    }

    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let (sut, loader) = makeSUT()
        let imageData = anyData()

        expect(sut, toCompleteWith: .success(imageData)) {
            loader.complete(with: imageData)
        }
    }

    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let (sut, loader) = makeSUT()
        let loaderError = anyNSError()

        expect(sut, toCompleteWith: .failure(loaderError)) {
            loader.complete(with: loaderError)
        }
    }

    func test_loadImageData_cachesImageDataOnLoaderSuccess() {
        let imageData = anyData()
        let url = anyURL()
        let cache = FeedImageCacheSpy()
        let (sut, loader) = makeSUT(with: cache)

        _ = sut.loadImageData(from: url) { _ in }
        loader.complete(with: imageData)

        XCTAssertEqual(cache.messages, [.save(data: imageData, for: url)], "Expected to cache loaded image data on success")
    }

    // MARK: - Helpers
    private func makeSUT(with cacheSpy: FeedImageCacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> (FeedImageDataLoaderCacheDecorator, LoaderSpy) {
        let loaderSpy = LoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loaderSpy, cache: cacheSpy)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loaderSpy, file: file, line: line)
        trackForMemoryLeaks(cacheSpy, file: file, line: line)
        return (sut, loaderSpy)
    }

    private func expect(
        _ sut: FeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case let (.success(receivedValue), .success(expectedValue)):
                XCTAssertEqual(receivedValue, expectedValue, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    private class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

        var loadedURLs: [URL] {
            return messages.map { $0.url }
        }

        var cancelledURLs = [URL]()

        private struct Task: FeedImageDataLoaderTask {
            var callback: () -> Void
            func cancel() {
                callback()
            }
        }

        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }

        func complete(with error: NSError, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }

        func complete(with data: Data, at index: Int = 0) {
            messages[index].completion(.success(data))
        }
    }

    private final class FeedImageCacheSpy: FeedImageDataCache {
        enum Message: Equatable {
            case save(data: Data, for: URL)
        }

        private(set) var messages = [Message]()

        func save(_ data: Data, for url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
            messages.append(.save(data: data, for: url))
        }
    }
}

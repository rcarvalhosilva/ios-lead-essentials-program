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

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {

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

    func test_loadImageData_doesNotCacheDataOnLoaderFailure() {
        let url = anyURL()
        let cache = FeedImageCacheSpy()
        let (sut, loader) = makeSUT(with: cache)

        _ = sut.loadImageData(from: url) { _ in }
        loader.complete(with: anyNSError())

        XCTAssertTrue(cache.messages.isEmpty, "Expected to not cache any image data on failure")
    }

    // MARK: - Helpers
    private func makeSUT(with cacheSpy: FeedImageCacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> (FeedImageDataLoaderCacheDecorator, FeedImageDataLoaderSpy) {
        let loaderSpy = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loaderSpy, cache: cacheSpy)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loaderSpy, file: file, line: line)
        trackForMemoryLeaks(cacheSpy, file: file, line: line)
        return (sut, loaderSpy)
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

import Foundation

public final class LocalFeedImageLoader {
    public enum Error: Swift.Error {
        case failed
        case notFound
    }

    private final class Task: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?

        init(completion: @escaping ((FeedImageDataLoader.Result) -> Void)) {
            self.completion = completion
        }

        func cancel() {
            preventFurtherCompletions()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }

        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
    }

    private let store: FeedImageDataStore

    public init(store: FeedImageDataStore) {
        self.store = store
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = Task(completion: completion)

        store.retrive(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            let result: FeedImageDataLoader.Result = result
                .mapError { _ in Error.failed }
                .flatMap { data in data.map { .success($0) } ?? .failure(Error.notFound) }
            task.complete(with: result)
        }

        return task
    }

    public typealias SaveResult = Result<Void, Swift.Error>
    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data: data, for: url) { _ in }
    }
}

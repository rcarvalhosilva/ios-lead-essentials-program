import Foundation

public final class LocalFeedImageLoader {
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

    public enum Error: Swift.Error {
        case failed
        case notFound
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
}

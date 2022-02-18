import Foundation

public final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore

    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader {
    public typealias LoadResult = FeedImageDataLoader.Result

    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }

    private final class LoadImageDataTask: FeedImageDataLoaderTask {
        private var completion: ((LoadResult) -> Void)?

        init(completion: @escaping ((LoadResult) -> Void)) {
            self.completion = completion
        }

        func cancel() {
            preventFurtherCompletions()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }

        func complete(with result: LoadResult) {
            completion?(result)
        }
    }

    public func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> FeedImageDataLoaderTask {
        let task = LoadImageDataTask(completion: completion)

        store.retrive(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            let result: FeedImageDataLoader.Result = result
                .mapError { _ in LoadError.failed }
                .flatMap { data in data.map { .success($0) } ?? .failure(LoadError.notFound) }
            task.complete(with: result)
        }

        return task
    }
}

extension LocalFeedImageDataLoader {
    public typealias SaveResult = Result<Void, Swift.Error>

    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data: data, for: url) { _ in }
    }
}

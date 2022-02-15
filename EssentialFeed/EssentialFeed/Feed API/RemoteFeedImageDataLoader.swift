private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
    private var completion: ((FeedImageDataLoader.Result) -> Void)?

    var wrapped: HTTPClientTask?

    init(_ completion: @escaping ((FeedImageDataLoader.Result) -> Void)) {
        self.completion = completion
    }

    func complete(with result: FeedImageDataLoader.Result) {
        completion?(result)
    }

    func cancel() {
        preventFurtherCompletion()
        wrapped?.cancel()
    }

    private func preventFurtherCompletion() {
        completion = nil
    }
}

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public init(client: HTTPClient) {
        self.client = client
    }

    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }

            switch result {
            case let .success((data, response)) where response.statusCode == 200 && !data.isEmpty:
                task.complete(with: .success(data))
            case .success:
                task.complete(with: .failure(Error.invalidData))
            case .failure:
                task.complete(with: .failure(Error.connectivity))
            }
        }

        return task
    }
}

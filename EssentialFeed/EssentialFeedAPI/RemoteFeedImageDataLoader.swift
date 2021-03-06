import EssentialFeed

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

            task.complete(with: result.mapError { _ in
                Error.connectivity
            }.flatMap { (data, response) in
                let isValidResponse = response.isOK && !data.isEmpty
                return isValidResponse ? .success(data) : .failure(Error.invalidData)
            })
        }

        return task
    }
}

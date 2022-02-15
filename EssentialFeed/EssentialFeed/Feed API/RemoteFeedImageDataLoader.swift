public final class HTTPClientTaskWrapper {
    private var completion: ((Result<Data, RemoteFeedImageDataLoader.Error>) -> Void)?

    var wrapped: HTTPClientTask?

    init(_ completion: @escaping ((Result<Data, RemoteFeedImageDataLoader.Error>) -> Void)) {
        self.completion = completion
    }

    func complete(with result: Result<Data, RemoteFeedImageDataLoader.Error>) {
        completion?(result)
    }

    public func cancel() {
        preventFurtherCompletion()
        wrapped?.cancel()
    }

    private func preventFurtherCompletion() {
        completion = nil
    }
}

public final class RemoteFeedImageDataLoader {
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public init(client: HTTPClient) {
        self.client = client
    }

    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> HTTPClientTaskWrapper {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }

            switch result {
            case let .success((data, response)) where response.statusCode == 200 && !data.isEmpty:
                task.complete(with: .success(data))
            case .success:
                task.complete(with: .failure(.invalidData))
            case .failure:
                task.complete(with: .failure(.connectivity))
            }
        }

        return task
    }
}

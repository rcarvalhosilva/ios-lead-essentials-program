import XCTest
import EssentialFeed

final class HTTPClientTaskWrapper {
    private var completion: ((Result<Data, RemoteFeedImageDataLoader.Error>) -> Void)?

    var wrapped: HTTPClientTask?

    init(_ completion: @escaping ((Result<Data, RemoteFeedImageDataLoader.Error>) -> Void)) {
        self.completion = completion
    }

    func complete(with result: Result<Data, RemoteFeedImageDataLoader.Error>) {
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

final class RemoteFeedImageDataLoader {
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    init(client: HTTPClient) {
        self.client = client
    }

    @discardableResult
    func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> HTTPClientTaskWrapper {
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

class LoadFeedImageDataFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_loadImageDataFromURL_requestsDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT()

        sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT()

        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let error = anyNSError()

        expect(sut, toCompleteWith: .failure(.connectivity)) {
            client.complete(with: error)
        }
    }

    func test_loadImageDataFromURL_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let data = anyData()

        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { (index, statusCode) in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                client.complete(withStatusCode: statusCode, data: data, at: index)
            }
        }
    }

    func test_loadImageDataFromURL_deliversErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData)
        }
    }

    func test_loadImageDataFromURL_deliversNonEmptyDataReceivedOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = anyData()

        expect(sut, toCompleteWith: .success(nonEmptyData)) {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        }
    }

    func test_loadImageDataFromURL_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)

        var capturedResults = [Result<Data, RemoteFeedImageDataLoader.Error>]()
        sut?.loadImageData(from: anyURL()) { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: anyData())

        XCTAssertTrue(capturedResults.isEmpty)
    }

    func test_cancelTask_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = anyURL()

        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled url until task is cancelled")

        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
    }

    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)

        var capturedResults = [Result<Data, RemoteFeedImageDataLoader.Error>]()
        let task = sut.loadImageData(from: anyURL()) { capturedResults.append($0) }
        task.cancel()

        client.complete(withStatusCode: 200, data: nonEmptyData)
        client.complete(withStatusCode: 404, data: anyData())
        client.complete(with: anyNSError())

        XCTAssertTrue(capturedResults.isEmpty, "Expected no received results after cancelling task")
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }

    private func expect(
        _ sut: RemoteFeedImageDataLoader,
        toCompleteWith expectedResult: Result<Data, RemoteFeedImageDataLoader.Error>,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let url = anyURL()

        let exp = expectation(description: "Wait for image load")
        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    final private class HTTPClientSpy: HTTPClient {
        private struct Task: HTTPClientTask {
            let callback: () -> Void

            func cancel() {
                callback()
            }
        }

        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        private(set) var cancelledURLs = [URL]()

        var requestedURLs: [URL] {
            messages.map { $0.url}
        }

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void)  -> HTTPClientTask {
            messages.append((url, completion))
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }

        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!

            messages[index].completion(.success((data, response)))
        }
    }

    private func anyData() -> Data {
        .init("any data".utf8)
    }
}

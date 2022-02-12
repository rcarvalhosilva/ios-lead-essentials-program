import XCTest
import EssentialFeed

final class RemoteFeedImageDataLoader {
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    init(client: HTTPClient) {
        self.client = client
    }

    func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success:
                completion(.failure(.invalidData))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
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
        let url = anyURL()
        let (sut, client) = makeSUT()
        let error = anyNSError()

        let exp = expectation(description: "Wait for image load")
        sut.loadImageData(from: url) { result in
            switch result {
            case let .failure(receivedError):
                XCTAssertEqual(receivedError, .connectivity)
            case .success:
                XCTFail("Expected failure with connectivity error, got \(result) instead")
            }
            exp.fulfill()
        }

        client.complete(with: error)

        wait(for: [exp], timeout: 1.0)
    }

    func test_loadImageDataFromURL_deliversErrorOnNon200HTTPResponse() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        let data = anyData()

        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { (index, statusCode) in
            let exp = expectation(description: "Wait for image load")

            sut.loadImageData(from: url) { result in
                switch result {
                case let .failure(receivedError):
                    XCTAssertEqual(receivedError, .invalidData)
                case .success:
                    XCTFail("Expected failure with invalidData error, got \(result) instead")
                }
                exp.fulfill()
            }

            client.complete(withStatusCode: 500, data: data, at: index)

            wait(for: [exp], timeout: 1.0)
        }
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }

    final private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()

        var requestedURLs: [URL] {
            messages.map { $0.url}
        }

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
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

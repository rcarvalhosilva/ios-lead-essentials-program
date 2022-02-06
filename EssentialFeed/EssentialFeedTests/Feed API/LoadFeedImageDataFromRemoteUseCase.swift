import XCTest
import EssentialFeed

final class RemoteFeedImageDataLoader {
    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func loadImageData(from url: URL) {
        client.get(from: url) { _ in }
    }
}

class LoadFeedImageDataFromRemoteUseCase: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_loadImageData_requestsDataFromGivenURL() {
        let url = anyURL()
        let (sut, client) = makeSUT()

        sut.loadImageData(from: url)

        XCTAssertEqual(client.requestedURLs, [url])
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (RemoteFeedImageDataLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

    final private class HTTPClientSpy: HTTPClient {
        private(set) var requestedURLs = [URL]()

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requestedURLs.append(url)
        }
    }
}

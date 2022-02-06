import XCTest
import EssentialFeed

final class RemoteFeedImageDataLoader {

}

class LoadFeedImageDataFromRemoteUseCase: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (RemoteFeedImageDataLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader()
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

    final private class HTTPClientSpy {
        let requestedURLs = [URL]()
    }
}

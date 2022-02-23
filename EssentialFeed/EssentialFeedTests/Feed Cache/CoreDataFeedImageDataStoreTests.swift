import EssentialFeed
import XCTest

class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImageData_deliversImageDataNotFoundWhenEmpty() {
        let sut = makeSUT()

        expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
    }

    func test_retrieveImageData_deliversNotFoundWhenStoreDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = URL(string: "https://stored-utl.com")!
        let nonMatchingURL = URL(string: "https://non-matching.com")!

        insert(anyData(), for: url, into: sut)
        
        expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingURL)
    }

    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() {
        let sut = makeSUT()
        let storedData = anyData()
        let matchingURL = URL(string: "https://matching-url.com")!

        insert(storedData, for: matchingURL, into: sut)

        expect(sut, toCompleteRetrievalWith: found(storedData), for: matchingURL)
    }

    func test_retrieveImageData_deliversLastInsertedValue() {
        let sut = makeSUT()
        let firstStoredData = Data("first".utf8)
        let secondStoredData = Data("second".utf8)
        let matchingURL = URL(string: "https://matching-url.com")!

        insert(firstStoredData, for: matchingURL, into: sut)
        insert(secondStoredData, for: matchingURL, into: sut)

        expect(sut, toCompleteRetrievalWith: found(secondStoredData), for: matchingURL)
    }

    func test_sideEffects_runSerially() {
        let sut = makeSUT()
        let url = anyURL()

        let op1 = expectation(description: "Operaion 1")
        sut.insert([localImage(url: url)], timestamp: Date()) { _ in op1.fulfill() }

        let op2 = expectation(description: "Operaion 2")
        sut.insert(data: anyData(), for: url) { _ in op2.fulfill() }

        let op3 = expectation(description: "Operaion 3")
        sut.insert(data: anyData(), for: url) { _ in op3.fulfill() }

        wait(for: [op1, op2, op3], timeout: 5.0, enforceOrder: true)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let url = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: url)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }

    private func found(_ data: Data) -> FeedImageDataStore.RetrievalResult {
        return .success(data)
    }

    private func expect(
        _ sut: CoreDataFeedStore,
        toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult,
        for url: URL,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrive(dataForURL: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedValue), .success(expectedValue)):
                XCTAssertEqual(receivedValue, expectedValue, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache insertion")
        let image = localImage(url: url)
        sut.insert([image], timestamp: .init()) { feedInsertionResult in
            switch feedInsertionResult {
            case let .failure(error):
                XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
                exp.fulfill()
            case .success:
                sut.insert(data: data, for: url) { imageInsertionResult in
                    if case let .failure(error) = imageInsertionResult {
                        XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
                    }
                    exp.fulfill()
                }
            }
        }

        wait(for: [exp], timeout: 1.0)
    }

    private func localImage(url: URL) -> LocalFeedImage {
        .init(id: .init(), description: "any", location: "any", url: url)
    }
}

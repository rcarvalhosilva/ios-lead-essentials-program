//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Rodrigo Carvalho on 14/11/21.
//

import XCTest


class URLSessionHTTPClient {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL) {
        session.dataTask(with: url)
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_createsDataTaskWithURL() {
        let url = URL(string: "https://any-url.com")!
        let session = URLSessionSpy()

        let sut = URLSessionHTTPClient(session: session)

        sut.get(from: url)

        XCTAssertEqual(session.receivedURLs, [url])
    }

    // MARK: - Helpers

    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()

        override init() {}


        override func dataTask(with url: URL) -> URLSessionDataTask {
            receivedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }

    private class FakeURLSessionDataTask: URLSessionDataTask {
        override init() {}
    }
}

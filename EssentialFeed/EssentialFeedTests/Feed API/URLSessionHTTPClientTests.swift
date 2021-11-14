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
        session.dataTask(with: url).resume()
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

    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)

        let sut = URLSessionHTTPClient(session: session)

        sut.get(from: url)

        XCTAssertEqual(task.resumeCallCount, 1)
    }

    // MARK: - Helpers

    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()
        var stubs = [URL: URLSessionDataTask]()

        override init() {}


        override func dataTask(with url: URL) -> URLSessionDataTask {
            receivedURLs.append(url)
            return stubs[url] ?? FakeURLSessionDataTask()
        }

        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }
    }

    private class FakeURLSessionDataTask: URLSessionDataTask {
        override init() {}

        override func resume() {
        }
    }

    private class URLSessionDataTaskSpy: URLSessionDataTask {
        private(set) var resumeCallCount = 0

        override init() {}

        override func resume() {
            resumeCallCount += 1
        }
    }
}

//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Rodrigo Carvalho on 10/11/21.
//

import XCTest
@testable import EssentialFeed

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL

    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load() {
        client.get(from: url)
    }
}


protocol HTTPClient {
    func get(from url: URL)
}

class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)


        sut.load()

        XCTAssertEqual(client.requestedURL, url)
    }

    // MARK: - Helpers
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?

        func get(from url: URL) {
            requestedURL = url
        }
    }

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
}

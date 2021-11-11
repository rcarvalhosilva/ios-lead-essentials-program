//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Rodrigo Carvalho on 10/11/21.
//

import XCTest
@testable import EssentialFeed

class RemoteFeedLoader {

}


class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
       _ = RemoteFeedLoader()

        XCTAssertNil(client.requestedURL)
    }
}

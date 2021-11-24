//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Rodrigo Carvalho on 24/11/21.
//

import XCTest

class LocalFeedLoader {

    init(store: FeedStore) {}
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)

        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

}

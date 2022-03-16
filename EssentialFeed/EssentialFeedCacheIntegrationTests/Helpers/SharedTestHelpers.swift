//
//  SharedTestHelpers.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Rodrigo Carvalho on 16/03/22.
//

import Foundation

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyData() -> Data {
    .init("any data".utf8)
}

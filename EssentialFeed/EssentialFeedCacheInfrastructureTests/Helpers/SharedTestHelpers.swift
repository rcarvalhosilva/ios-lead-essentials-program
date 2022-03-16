//
//  SharedTestHelpers.swift
//  EssentialFeedCacheTests
//
//  Created by Rodrigo Carvalho on 15/03/22.
//

import Foundation

func anyNSError(domain: String = "any domain") -> NSError {
    NSError(domain: domain, code: 400, userInfo: nil)
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyData() -> Data {
    .init("any data".utf8)
}

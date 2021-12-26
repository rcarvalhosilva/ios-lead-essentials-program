//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Rodrigo Carvalho on 04/12/21.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any domain", code: 400, userInfo: nil)
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

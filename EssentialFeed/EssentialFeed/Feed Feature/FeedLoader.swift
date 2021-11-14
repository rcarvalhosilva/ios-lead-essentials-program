//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Rodrigo Carvalho on 10/11/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}

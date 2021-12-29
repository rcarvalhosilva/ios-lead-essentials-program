//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Rodrigo Carvalho on 10/11/21.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result) -> Void)
}

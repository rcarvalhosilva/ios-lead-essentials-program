//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Rodrigo Carvalho on 10/11/21.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}

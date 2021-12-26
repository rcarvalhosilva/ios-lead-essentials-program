//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Rodrigo Carvalho on 27/11/21.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}

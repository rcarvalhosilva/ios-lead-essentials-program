//
//  FeedCacheIntegrationTestsHelpers.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Rodrigo Carvalho on 16/03/22.
//

import Foundation
import EssentialFeed
import EssentialFeedCache

func uniqueImage() -> FeedImage {
    .init(id: .init(), description: "any", location: "any", url: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map {
        LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
    }
    return (models, local)
}

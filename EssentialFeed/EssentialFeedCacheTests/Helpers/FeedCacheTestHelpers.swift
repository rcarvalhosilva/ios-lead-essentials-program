//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Rodrigo Carvalho on 04/12/21.
//

import EssentialFeed
import EssentialFeedCache
import Foundation

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

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        adding(days: -feedCacheMaxAgeInDays)
    }

    private var feedCacheMaxAgeInDays: Int {
        7
    }

    private func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}

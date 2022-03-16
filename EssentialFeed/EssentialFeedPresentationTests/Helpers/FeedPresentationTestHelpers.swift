//
//  FeedPresentationTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Rodrigo Carvalho on 15/03/22.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
    .init(id: .init(), description: "any", location: "any", url: anyURL())
}

func uniqueImageFeed() -> [FeedImage] {
    [uniqueImage(), uniqueImage()]
}

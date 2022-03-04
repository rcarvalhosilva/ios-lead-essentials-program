import Foundation
import EssentialFeed

func anyNSError() -> NSError {
    NSError(domain: "any domain", code: 0)
}

func anyURL() -> URL {
    URL(string: "www.any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
    [FeedImage(id: UUID(), description: "any", location: "any location", url: anyURL())]
}

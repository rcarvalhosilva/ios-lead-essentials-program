//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Rodrigo Carvalho on 19/12/21.
//

import Foundation

public class CodableFeedStore: FeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date

        var localFeed: [LocalFeedImage] {
            feed.map { $0.local }
        }
    }

    private struct CodableFeedImage: Codable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL

        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }

        init(localFeedImage: LocalFeedImage) {
            self.id = localFeedImage.id
            self.description = localFeedImage.description
            self.location = localFeedImage.location
            self.url = localFeedImage.url
        }
    }

    private let storeURL: URL

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }

        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        do {
            let enconder = JSONEncoder()
            let enconded = try enconder.encode(Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp))
            try enconded.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    public func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            return completion(nil)
        }

        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
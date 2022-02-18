import Foundation
import EssentialFeed

final class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Messages: Equatable {
        case retrieve(dataFor: URL)
        case insert(data: Data, for: URL)
    }

    private(set) var receivedMessages = [Messages]()
    private(set) var retrievalCompletions = [(FeedImageDataStore.Result) -> Void]()

    func retrive(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
        receivedMessages.append(.retrieve(dataFor: url))
        retrievalCompletions.append(completion)
    }

    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }

    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }

    func insert(data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, for: url))
    }
}

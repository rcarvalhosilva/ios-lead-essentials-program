import Foundation

public protocol FeedImageDataStore {
    typealias RetrieveResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

    func retrive(dataForURL url: URL, completion: @escaping (RetrieveResult) -> Void)
    func insert(data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}

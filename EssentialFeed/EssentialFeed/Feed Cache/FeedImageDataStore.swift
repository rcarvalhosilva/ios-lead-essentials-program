import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

    func retrive(dataForURL url: URL, completion: @escaping (Result) -> Void)
    func insert(data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}

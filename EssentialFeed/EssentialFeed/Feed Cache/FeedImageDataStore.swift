import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>

    func retrive(dataForURL url: URL, completion: @escaping (Result) -> Void)
}

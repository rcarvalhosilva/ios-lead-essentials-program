import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any domain", code: 0)
}

func anyURL() -> URL {
    URL(string: "www.any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

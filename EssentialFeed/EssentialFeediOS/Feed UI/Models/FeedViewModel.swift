import EssentialFeed

final class FeedViewModel {
    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    private(set) var isLoading: Bool = false {
        didSet {
            onChange?(self)
        }
    }

    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoaded: (([FeedImage]) -> Void)?

    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoaded?(feed)
            }

            self?.isLoading = false
        }
    }
}

import Combine
import EssentialFeed
import EssentialFeedPresentation
import EssentialFeediOS

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: () -> FeedLoader.Publisher
    var presenter: FeedPresenter?
    var cancellable: Cancellable?

    init(
        feedLoader: @escaping () -> FeedLoader.Publisher
    ) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()

        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        } receiveValue: { [weak self] feed in
            self?.presenter?.didFinishLoadingFeed(with: feed)
        }
    }
}

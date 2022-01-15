import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let viewModel = FeedViewModel(feedLoader: feedLoader)
        let presenter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(presenter: presenter)
        let feedController = FeedViewController(refreshController: refreshController)
        viewModel.onFeedLoaded = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        presenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)
        presenter.loadingView = refreshController
        return feedController
    }

    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void  {
        { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                return FeedImageCellController(
                    viewModel: FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init)
                )
            }
        }
    }
}

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader

    init(
        controller: FeedViewController?,
        imageLoader: FeedImageDataLoader
    ) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(feed: [FeedImage]) {
        controller?.tableModel = feed.map { model in
            return FeedImageCellController(
                viewModel: FeedImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init)
            )
        }
    }
}

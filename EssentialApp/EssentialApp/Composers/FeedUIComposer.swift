import EssentialFeed
import EssentialFeedPresentation
import EssentialFeediOS 
import UIKit

final class FeedUIComposer {
    private init() {}

    static func feedComposedWith(feedLoader: @escaping () -> FeedLoader.Publisher, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: { feedLoader().dispatchOnMainQueue() })
        let feedController = makeFeedViewControllerWith(delegate: presentationAdapter, title: FeedPresenter.title)
        let presenter = FeedPresenter(
            feedView: FeedViewAdapter(
                controller: feedController,
                imageLoader: MainQueueDispatchDecorator(imageLoader)
            ),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController)
        )
        presentationAdapter.presenter = presenter
        return feedController
    }

    static func makeFeedViewControllerWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
         let bundle = Bundle(for: FeedViewController.self)
         let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
         let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
         feedController.delegate = delegate
         feedController.title = title
         return feedController
     }
}

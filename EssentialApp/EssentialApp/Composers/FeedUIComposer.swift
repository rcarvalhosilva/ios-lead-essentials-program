import EssentialFeed
import EssentialFeedPresentation
import EssentialFeediOS 
import UIKit

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: MainQueueDispatchDecorator(feedLoader))
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

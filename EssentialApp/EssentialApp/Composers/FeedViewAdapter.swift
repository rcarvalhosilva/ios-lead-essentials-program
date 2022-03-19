import UIKit
import EssentialFeed
import EssentialFeedPresentation
import EssentialFeediOS

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher

    init(
        controller: FeedViewController?,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
    ) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(_ viewModel: FeedViewModel) {
        let tableModel: [FeedImageCellController] = viewModel.feed.map { model in
            let presentationAdapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>>(imageLoader: imageLoader, model: model)

            let view = FeedImageCellController(
                delegate: presentationAdapter
            )

            presentationAdapter.presenter = FeedImagePresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init
            )

            return view
        }

        controller?.display(tableModel)
    }
}

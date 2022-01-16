import UIKit

protocol FeedImageViewDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellController: FeedImageView {
    private let delegate: FeedImageViewDelegate

    init(delegate: FeedImageViewDelegate) {
        self.delegate = delegate
    }
    
    private lazy var cell = FeedImageCell()

    func view() -> UITableViewCell {
        delegate.didRequestImage()
        return cell
    }

    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.feedImageContainer.isShimmering = viewModel.isLoading
        cell.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell.feedImageView.image = viewModel.image

        cell.onRetry = delegate.didRequestImage
    }

    func preload() {
        delegate.didRequestImage()
    }

    func cancelLoad() {
        delegate.didCancelImageRequest()
    }
}

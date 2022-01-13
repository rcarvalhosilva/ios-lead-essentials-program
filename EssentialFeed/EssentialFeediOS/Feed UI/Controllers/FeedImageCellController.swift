import UIKit

final class FeedImageCellController {
    private let viewModel: FeedImageViewModel

    init(viewModel: FeedImageViewModel) {
        self.viewModel = viewModel
    }

    func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImageData()
        return cell
    }

    private func binded(_ view: FeedImageCell) -> FeedImageCell {
        view.locationContainer.isHidden = !viewModel.hasLocation
        view.locationLabel.text = viewModel.location
        view.descriptionLabel.text = viewModel.description
        view.onRetry = viewModel.loadImageData

        viewModel.onImageLoadingStateChange = { [weak view] isLoading in
            view?.feedImageContainer.isShimmering = isLoading
        }

        viewModel.onShouldRetryImageLoadStateChange = { [weak view] shouldRetry in
            view?.feedImageRetryButton.isHidden = !shouldRetry
        }

        viewModel.onImageLoad = { [weak view] image in
            view?.feedImageView.image = image
        }

        return view
    }

    func preload() {
        viewModel.loadImageData()
    }

    func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
}

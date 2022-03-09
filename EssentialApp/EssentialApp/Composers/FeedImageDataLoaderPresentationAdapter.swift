import EssentialFeed
import EssentialFeediOS

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView>: FeedImageViewDelegate {
    private var task: FeedImageDataLoaderTask?
    private let imageLoader: FeedImageDataLoader
    private let model: FeedImage

    var presenter: FeedImagePresenter<View>?

    init(imageLoader: FeedImageDataLoader, model: FeedImage) {
        self.imageLoader = imageLoader
        self.model = model
    }

    func didRequestImage() {
        presenter?.didStartLoadingImage(for: model)

        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.handle(result)
        }
    }

    private func handle(_ result: FeedImageDataLoader.Result) {
        do {
            let imageData = try result.get()
            presenter?.didFinishLoadingImage(with: imageData, for: model)
        } catch  {
            presenter?.didFinishLoadingImage(with: error, for: model)
        }
    }

    func didCancelImageRequest() {
        task?.cancel()
        task = nil
    }
}

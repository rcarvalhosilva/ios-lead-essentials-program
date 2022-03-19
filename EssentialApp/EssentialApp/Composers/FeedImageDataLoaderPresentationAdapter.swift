import Combine
import Foundation
import EssentialFeed
import EssentialFeedPresentation
import EssentialFeediOS

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView>: FeedImageViewDelegate {
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private let model: FeedImage

    var presenter: FeedImagePresenter<View>?
    var cancellable: Cancellable?

    init(imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher, model: FeedImage) {
        self.imageLoader = imageLoader
        self.model = model
    }

    func didRequestImage() {
        presenter?.didStartLoadingImage(for: model)
        let model = self.model

        cancellable = imageLoader(model.url).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.presenter?.didFinishLoadingImage(with: error, for: model)
            }
        } receiveValue: { [weak self] imageData in
            self?.presenter?.didFinishLoadingImage(with: imageData, for: model)
        }
    }

    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}

import EssentialFeed

protocol FeedImageView {
    associatedtype Image

    func display(_ model: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let imageTransformer: (Data) -> Image?
    private let view: View

    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }

    func didStartLoadingImage(for model: FeedImage) {
        let viewModel = FeedImageViewModel<Image>(
            image: nil,
            location: model.location,
            description: model.description,
            isLoading: true,
            shouldRetry: false
        )

        view.display(viewModel)
    }

    private struct InvalidImageDataError: Error {}

    func didFinishLoadingImage(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImage(with: InvalidImageDataError(), for: model)
        }
        
        let viewModel = FeedImageViewModel<Image>(
            image: image,
            location: model.location,
            description: model.description,
            isLoading: false,
            shouldRetry: false
        )
        view.display(viewModel)
    }

    func didFinishLoadingImage(with error: Error, for model: FeedImage) {
        let viewModel = FeedImageViewModel<Image>(
            image: nil,
            location: model.location,
            description: model.description,
            isLoading: false,
            shouldRetry: true
        )
        
        view.display(viewModel)
    }
}

public protocol FeedImageView {
    associatedtype Image

    func display(_ model: FeedImageViewModel<Image>)
}

public final class FeedImagePresenter<View: FeedImageView> {
    public typealias Image = View.Image
    private let imageTransformer: (Data) -> Image?
    private let view: View

    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }

    public func didStartLoadingImage(for model: FeedImage) {
        let viewModel = FeedImageViewModel<Image>(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false
        )

        view.display(viewModel)
    }

    public func didFinishLoadingImage(with data: Data, for model: FeedImage) {
        let image = imageTransformer(data)

        let viewModel = FeedImageViewModel<Image>(
            description: model.description,
            location: model.location,
            image: image,
            isLoading: false,
            shouldRetry: image == nil
        )

        return view.display(viewModel)
    }

    public func didFinishLoadingImage(with error: Error, for model: FeedImage) {
        let viewModel = FeedImageViewModel<Image>(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: false,
            shouldRetry: true
        )

        view.display(viewModel)
    }
}

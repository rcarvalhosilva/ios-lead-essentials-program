public protocol FeedImageView {
    associatedtype Image

    func display(_ model: FeedImageViewModel<Image>)
}

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool

    var hasLocation: Bool {
        return location != nil
    }
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

    private struct InvalidImageDataError: Error {}

    public func didFinishLoadingImage(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImage(with: InvalidImageDataError(), for: model)
        }

        let viewModel = FeedImageViewModel<Image>(
            description: model.description,
            location: model.location,
            image: image,
            isLoading: false,
            shouldRetry: false
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

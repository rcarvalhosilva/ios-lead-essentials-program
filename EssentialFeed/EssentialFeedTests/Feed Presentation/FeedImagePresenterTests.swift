import XCTest
import EssentialFeed

protocol FeedImageView {
    associatedtype Image

    func display(_ model: FeedImageViewModel<Image>)
}

struct FeedImageViewModel<Image> {
     let description: String?
     let location: String?
     let image: Image?
     let isLoading: Bool
     let shouldRetry: Bool

     var hasLocation: Bool {
         return location != nil
     }
 }

final class FeedImagePresenter<View: FeedImageView> {
    typealias Image = View.Image
    private let imageTransformer: (Data) -> Image?
    private let view: View

    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }

    func didStartLoadingImage(for model: FeedImage) {
        let viewModel = FeedImageViewModel<Image>(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false
        )

        view.display(viewModel)
    }

    func didFinishLoadingImage(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            let viewModel = FeedImageViewModel<Image>(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: false,
                shouldRetry: true
            )

            return view.display(viewModel)
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

    func didFinishLoadingImage(with error: Error, for model: FeedImage) {
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

class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no messages to view")
    }

    func test_didStartLoadingImage_displaysLoadingImage() {
        let (sut, view) = makeSUT()
        let image = uniqueImage()

        sut.didStartLoadingImage(for: image)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertNil(message?.image)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.description, image.description)
    }

    func test_didFinishLoadingImage_displaysRetryWhenImageTransformationFails() {
        let (sut, view) = makeSUT(imageTransformer: alwaysFailingImageTransformer)
        let image = uniqueImage()
        let data = Data()

        sut.didFinishLoadingImage(with: data, for: image)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertNil(message?.image)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.description, image.description)
    }

    func test_didFinishLoadingImage_displaysImageWhenTransformationSucceeds() {
        let image = uniqueImage()
        let data = Data()
        let transformedData = ViewSpy.AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })

        sut.didFinishLoadingImage(with: data, for: image)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.image, transformedData)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.description, image.description)
    }

    func test_didFinishLoadingImageWithError_displaysRetry() {
        let (sut, view) = makeSUT()
        let image = uniqueImage()
        let error = anyNSError()

        sut.didFinishLoadingImage(with: error, for: image)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertNil(message?.image)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.description, image.description)
    }

    // MARK: - Helpers

    private func makeSUT(
        imageTransformer: @escaping (Data) -> ViewSpy.Image? = { _ in nil },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (FeedImagePresenter<ViewSpy>, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter<ViewSpy>(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    private func alwaysFailingImageTransformer(data: Data) -> ViewSpy.Image? {
        return nil
    }

    private final class ViewSpy: FeedImageView {
        struct AnyImage: Equatable {}

        private(set) var messages = [FeedImageViewModel<AnyImage>]()

        func display(_ model: FeedImageViewModel<AnyImage>) {
            messages.append(model)
        }
    }
}

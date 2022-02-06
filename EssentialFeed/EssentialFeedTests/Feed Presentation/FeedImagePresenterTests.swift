import XCTest
import EssentialFeed

protocol FeedImageView {
    func display(_ model: FeedImageViewModel)
}

final class FeedImagePresenter {
    private let imageTransformer: (Data) -> Any?
    private let view: FeedImageView

    init(view: FeedImageView, imageTransformer: @escaping (Data) -> Any?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }

    func didStartLoadingImage(for model: FeedImage) {
        let viewModel = FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false
        )

        view.display(viewModel)
    }

    func didFinishLoadingImage(with data: Data, for model: FeedImage) {
        guard imageTransformer(data) != nil else {
            let viewModel = FeedImageViewModel(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: false,
                shouldRetry: true
            )

            return view.display(viewModel)
        }
    }
}

struct FeedImageViewModel {
     let description: String?
     let location: String?
     let image: Any?
     let isLoading: Bool
     let shouldRetry: Bool

     var hasLocation: Bool {
         return location != nil
     }
 }

final class ViewSpy: FeedImageView {
    private(set) var messages = [FeedImageViewModel]()

    func display(_ model: FeedImageViewModel) {
        messages.append(model)
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

    // MARK: - Helpers

    private func makeSUT(
        imageTransformer: @escaping (Data) -> Any? = { _ in nil },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (FeedImagePresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    private func alwaysFailingImageTransformer(data: Data) -> Any? {
        return nil
    }
}

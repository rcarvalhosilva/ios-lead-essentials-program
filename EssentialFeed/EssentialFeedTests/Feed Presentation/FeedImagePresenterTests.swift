import XCTest
import EssentialFeed

protocol FeedImageView {
    func display(_ model: FeedImageViewModel)
}

final class FeedImagePresenter {
    private let view: FeedImageView

    init(view: FeedImageView) {
        self.view = view
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
        let view = ViewSpy()
        let _ = FeedImagePresenter(view: view)

        XCTAssertTrue(view.messages.isEmpty, "Expected no messages to view")
    }

    func test_didStartLoadingImage_displaysLoadingImage() {
        let view = ViewSpy()
        let image = uniqueImage()
        let sut = FeedImagePresenter(view: view)

        sut.didStartLoadingImage(for: image)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertNil(message?.image)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.description, image.description)
    }
}

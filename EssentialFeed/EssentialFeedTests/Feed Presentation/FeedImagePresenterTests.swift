import XCTest

final class FeedImagePresenter {
    init(view: Any) {

    }
}

final class ViewSpy {
    let messages = [Any]()
}

class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        let _ = FeedImagePresenter(view: view)

        XCTAssertTrue(view.messages.isEmpty, "Expected no messages to view")
    }
}

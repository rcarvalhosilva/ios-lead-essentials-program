struct FeedImageViewModel<Image> {
    let image: Image?
    let location: String?
    let description: String?
    let isLoading: Bool
    let shouldRetry: Bool

    var hasLocation: Bool {
        location != nil
    }
}

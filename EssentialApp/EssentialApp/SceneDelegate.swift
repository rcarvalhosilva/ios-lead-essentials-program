import Combine
import CoreData
import EssentialFeed
import EssentialFeedAPI
import EssentialFeedAPIInfrastructure
import EssentialFeediOS
import EssentialFeedCache
import EssentialFeedCacheInfrastructure
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()

    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite")
        )
    }()

    private lazy var localFeedLoader: LocalFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
    private lazy var  localImageLoader = LocalFeedImageDataLoader(store: store)

    private lazy var remoteFeedLoader: RemoteFeedLoader = {
        let feedUrl = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        return RemoteFeedLoader(url: feedUrl, client: httpClient)
    }()

    private lazy var remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        
        configureWindow()
    }

    func configureWindow() {
        let feedViewController = FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalImageDataLoaderWithRemoteFallback
        )

        window?.rootViewController = UINavigationController(rootViewController: feedViewController)

        window?.makeKeyAndVisible()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }

    private func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher {
        return remoteFeedLoader.loadPublisher()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }

    private func makeLocalImageDataLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                self.remoteImageLoader
                    .loadImageDataPublisher(from: url)
                    .caching(to: self.localImageLoader, using: url)
            })
    }
}

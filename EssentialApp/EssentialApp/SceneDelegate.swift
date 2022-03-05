import EssentialFeed
import EssentialFeediOS
import CoreData
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let _ = (scene as? UIWindowScene) else { return }

        let feedUrl = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)

        let remoteFeedLoader = RemoteFeedLoader(url: feedUrl, client: client)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: client)

        let feedViewController = FeedUIComposer.feedComposedWith(
            feedLoader: remoteFeedLoader,
            imageLoader: remoteImageLoader
        )

        window?.rootViewController = feedViewController
    }
}

import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
    var local: LocalFeedImage {
        LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }

    static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        NSOrderedSet(array: localFeed.map { local in
            let managedImage = ManagedFeedImage(context: context)
            managedImage.id = local.id
            managedImage.url = local.url
            managedImage.imageDescription = local.description
            managedImage.location = local.location
            return managedImage
        })
    }
}

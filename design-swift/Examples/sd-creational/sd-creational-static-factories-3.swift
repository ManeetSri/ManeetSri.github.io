// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-static-factories.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

final class ImageCache: Sendable {
    let name: String
    init(name: String) { self.name = name }

    static var computed: ImageCache { ImageCache(name: "computed") }
    static let stored = ImageCache(name: "stored")
}

print(ImageCache.computed === ImageCache.computed)
print(ImageCache.stored === ImageCache.stored)

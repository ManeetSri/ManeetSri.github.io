// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-factory-method.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

protocol PostSource {
    func posts() throws -> [String]
}

struct NetworkPostSource: PostSource {
    func posts() throws -> [String] { ["(pretend this came from the network)"] }
}

class FeedLoader {
    // The factory method: subclasses decide which source to use
    func makeSource() -> any PostSource {
        NetworkPostSource()
    }

    // The creator's own logic, which uses whatever the factory method returns
    func headlines() -> [String] {
        do {
            return try makeSource().posts().map { $0.uppercased() }
        } catch {
            return ["Feed unavailable"]
        }
    }
}

struct CannedPostSource: PostSource {
    let canned: [String]
    func posts() throws -> [String] { canned }
}

struct FailingPostSource: PostSource {
    struct Offline: Error {}
    func posts() throws -> [String] { throw Offline() }
}

// In a test target, these would be the test doubles
final class CannedFeedLoader: FeedLoader {
    override func makeSource() -> any PostSource {
        CannedPostSource(canned: ["swift 6 is out", "ios 18 ships"])
    }
}

final class OfflineFeedLoader: FeedLoader {
    override func makeSource() -> any PostSource {
        FailingPostSource()
    }
}

print(CannedFeedLoader().headlines().joined(separator: " | "))
print(OfflineFeedLoader().headlines().joined(separator: " | "))

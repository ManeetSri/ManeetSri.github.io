// Generated from src/dsa/design/content/lessons/sd-resilience-patterns/sd-resilience-futures-async.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Profile: Sendable { let name: String }
struct Feed: Sendable { let posts: Int }

func loadProfile() async throws -> Profile { Profile(name: "Maneet") }
func loadFeed() async throws -> Feed { Feed(posts: 20) }

// "all": start both, then wait for both. Either failing cancels the other.
func loadHome() async throws -> String {
    async let profile = loadProfile()
    async let feed = loadFeed()
    let (who, page) = try await (profile, feed)
    return "\(who.name): \(page.posts) posts"
}

// "race": the first mirror to answer wins, and the others are cancelled
func fetch(from mirror: String, takes delay: Duration) async throws -> String {
    do {
        try await Task.sleep(for: delay)
    } catch {
        print("\(mirror) cancelled")
        throw error
    }
    return mirror
}

func fastestMirror() async throws -> String {
    try await withThrowingTaskGroup(of: String.self) { group in
        group.addTask { try await fetch(from: "us-east", takes: .seconds(30)) }
        group.addTask { try await fetch(from: "eu-west", takes: .zero) }
        defer { group.cancelAll() }
        guard let winner = try await group.next() else { throw CancellationError() }
        return winner
    }
}

print(try await loadHome())
print("Fastest:", try await fastestMirror())

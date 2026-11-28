// Generated from src/dsa/design/content/lessons/sd-diagnostics/sd-diag-typed-throws.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Post: Sendable {
    let id: Int
}

enum FeedError: Error {
    case offline
    case sessionExpired
}

protocol FeedRepository: Sendable {
    func latest() async throws(FeedError) -> [Post]
}

// Not throwing at all still satisfies `throws(FeedError)`: it's `throws(Never)`, a subtype
struct CannedFeed: FeedRepository {
    let posts: [Post]
    func latest() async -> [Post] { posts }
}

// A stub configured with an outcome: storing one is what Result is for
struct StubFeed: FeedRepository {
    let outcome: Result<[Post], FeedError>
    func latest() async throws(FeedError) -> [Post] { try outcome.get() }
}

// Starts loading the feed during launch; the first screen awaits it later
final class FeedPrefetch: Sendable {
    private let task: Task<Result<[Post], FeedError>, Never>

    init(repository: any FeedRepository) {
        // A Task can't throw a typed error, so this one never throws: it returns a Result
        task = Task {
            do throws(FeedError) {
                return .success(try await repository.latest())
            } catch {
                return .failure(error)
            }
        }
    }

    func posts() async throws(FeedError) -> [Post] {
        try await task.value.get()     // `get()` rethrows the stored FeedError, still typed
    }
}

func headline(_ prefetch: FeedPrefetch) async -> String {
    do throws(FeedError) {
        return "\(try await prefetch.posts().count) new posts"
    } catch {
        switch error {                 // a FeedError, so no default is needed
        case .offline: return "Offline: showing saved posts"
        case .sessionExpired: return "Sign in to see new posts"
        }
    }
}

let repositories: [any FeedRepository] = [
    CannedFeed(posts: [Post(id: 1), Post(id: 2), Post(id: 3)]),
    StubFeed(outcome: .failure(.offline)),
    StubFeed(outcome: .failure(.sessionExpired)),
]
for repository in repositories {
    print(await headline(FeedPrefetch(repository: repository)))
}

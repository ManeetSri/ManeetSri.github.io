// Generated from src/dsa/design/content/lessons/sd-coupling/sd-coupling-stable-dependencies.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// Feed module: the policy, and the abstraction it owns, in its own words
struct Post: Sendable {
    let id: Int
    let title: String
}

struct FeedPage: Sendable {
    let posts: [Post]
    let nextCursor: Int?   // nil on the last page
}

protocol FeedLoading: Sendable {
    func page(after cursor: Int?) async throws -> FeedPage
}

@MainActor
final class FeedViewModel {
    private let loader: any FeedLoading
    private var nextCursor: Int?
    private(set) var posts: [Post] = []
    private(set) var reachedEnd = false

    init(loader: any FeedLoading) {
        self.loader = loader
    }

    func loadMore() async {
        guard !reachedEnd else { return }
        do {
            let page = try await loader.page(after: nextCursor)
            posts += page.posts
            nextCursor = page.nextCursor
            reachedEnd = page.nextCursor == nil
        } catch {
            // A real view model would expose an error state here
        }
    }
}

// Tests, previews or a second app: anything that conforms will do
struct CannedFeed: FeedLoading {
    let pages: [[String]]

    func page(after cursor: Int?) async throws -> FeedPage {
        let index = cursor ?? 0
        let posts = pages[index].enumerated().map { Post(id: index * 10 + $0.offset, title: $0.element) }
        return FeedPage(posts: posts, nextCursor: index + 1 < pages.count ? index + 1 : nil)
    }
}

let viewModel = FeedViewModel(loader: CannedFeed(pages: [["Hello", "Swift 6"], ["Coupling"]]))
for _ in 1...3 {
    await viewModel.loadMore()
    print(viewModel.posts.map(\.title), viewModel.reachedEnd)
}

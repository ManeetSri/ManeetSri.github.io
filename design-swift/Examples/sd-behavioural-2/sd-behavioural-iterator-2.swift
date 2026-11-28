// Generated from src/dsa/design/content/lessons/sd-behavioural-2/sd-behavioural-iterator.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Page: Sendable {
    let items: [String]
    let nextCursor: String?
}

struct PageNotFound: Error {}

// A stand-in for the feed API: three pages, and a log of the requests it served
actor FakeFeedAPI {
    private(set) var requests: [String] = []
    private let pages = [
        "first": Page(items: ["a", "b"], nextCursor: "p2"),
        "p2": Page(items: ["c", "d"], nextCursor: "p3"),
        "p3": Page(items: ["e"], nextCursor: nil),
    ]

    func page(after cursor: String?) throws -> Page {
        let key = cursor ?? "first"
        requests.append(key)
        guard let page = pages[key] else { throw PageNotFound() }
        return page
    }
}

// Every item in the feed, one at a time. Callers never see pages or cursors.
struct FeedItems: AsyncSequence {
    typealias Element = String
    let api: FakeFeedAPI

    struct AsyncIterator: AsyncIteratorProtocol {
        let api: FakeFeedAPI
        var buffer: [String] = []
        var cursor: String?
        var isLastPage = false

        mutating func next() async throws -> String? {
            while buffer.isEmpty {
                if isLastPage { return nil }
                try Task.checkCancellation()
                let page = try await api.page(after: cursor)   // fetch only when asked
                buffer = page.items.reversed()
                cursor = page.nextCursor
                isLastPage = page.nextCursor == nil
            }
            return buffer.popLast()
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(api: api)
    }
}

let api = FakeFeedAPI()
for try await item in FeedItems(api: api) {
    print("show", item)
    if item == "c" { break }   // the user stopped scrolling
}
print("requests:", await api.requests)

let fresh = FakeFeedAPI()
var everything: [String] = []
for try await item in FeedItems(api: fresh) {
    everything.append(item)
}
print("all:", everything, "requests:", await fresh.requests)

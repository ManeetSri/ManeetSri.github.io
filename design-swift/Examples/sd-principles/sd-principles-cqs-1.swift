// Generated from src/dsa/design/content/lessons/sd-principles/sd-principles-cqs.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Page {
    let number: Int
    let items: [String]
}

final class FeedPaginator {
    private let pages: [[String]]
    private var next = 1

    init(pages: [[String]]) {
        self.pages = pages
    }

    // Reads like a question, but asking it changes the answer
    var currentPage: Page? {
        guard next <= pages.count else { return nil }
        defer { next += 1 }
        return Page(number: next, items: pages[next - 1])
    }
}

let pages = [["a1", "a2"], ["b1", "b2"], ["c1"]]
let paginator = FeedPaginator(pages: pages)
print("Debug: about to show page \(paginator.currentPage?.number ?? 0)")
if let page = paginator.currentPage {
    print("Showing page \(page.number): \(page.items)")
}

// Separated: one command changes state, queries only report it
final class FeedPager {
    private let pages: [[String]]
    private(set) var items: [String] = []
    private(set) var loadedPages = 0

    init(pages: [[String]]) {
        self.pages = pages
    }

    var hasMore: Bool { loadedPages < pages.count }

    func loadNextPage() {
        guard hasMore else { return }
        items += pages[loadedPages]
        loadedPages += 1
    }
}

let pager = FeedPager(pages: pages)
pager.loadNextPage()
print("Debug: \(pager.loadedPages) page loaded, more: \(pager.hasMore)")
print("Showing \(pager.items)")

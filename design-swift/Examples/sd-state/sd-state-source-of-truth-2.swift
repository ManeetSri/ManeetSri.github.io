// Generated from src/dsa/design/content/lessons/sd-state/sd-state-source-of-truth.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Article: Identifiable {
    let id: Int
    var title: String
    var isFavourite = false
}

/// The one owner of articles. Screens hold ids and ask it; only it changes an article.
final class ArticleStore {
    private(set) var articles: [Article.ID: Article] = [:]
    private(set) var feed: [Article.ID] = []

    func load(_ incoming: [Article]) {
        for article in incoming {
            articles[article.id] = article
        }
        feed = incoming.map(\.id)
    }

    func toggleFavourite(_ id: Article.ID) {
        articles[id]?.isFavourite.toggle()
    }
}

let store = ArticleStore()
store.load([
    Article(id: 1, title: "Swift 6 in practice"),
    Article(id: 2, title: "Observation, explained"),
])

let shownInDetail: Article.ID = 1   // the detail screen is handed an id, not a copy
store.toggleFavourite(shownInDetail)

for id in store.feed {
    if let article = store.articles[id] {
        print(article.title, article.isFavourite ? "★" : "☆")
    }
}

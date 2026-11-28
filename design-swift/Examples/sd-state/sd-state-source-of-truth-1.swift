// Generated from src/dsa/design/content/lessons/sd-state/sd-state-source-of-truth.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Article {
    let id: Int
    var title: String
    var isFavourite = false
}

var feed = [
    Article(id: 1, title: "Swift 6 in practice"),
    Article(id: 2, title: "Observation, explained"),
]

// The detail screen is handed the article it shows: a struct, so a copy
var detail = feed[0]
detail.isFavourite = true

print("Detail screen: favourite =", detail.isFavourite)
print("Feed row:      favourite =", feed[0].isFavourite)

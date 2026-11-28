// Generated from src/dsa/design/content/lessons/sd-behavioural-1/sd-behavioural-strategy.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct Post {
    let title: String
    let likes: Int
    let hoursOld: Int
}

/// One way of ordering a feed
protocol RankingStrategy {
    var name: String { get }
    func rank(_ posts: [Post]) -> [Post]
}

struct Newest: RankingStrategy {
    let name = "Newest"

    func rank(_ posts: [Post]) -> [Post] {
        posts.sorted { $0.hoursOld < $1.hoursOld }
    }
}

struct MostLiked: RankingStrategy {
    let name = "Most liked"

    func rank(_ posts: [Post]) -> [Post] {
        posts.sorted(using: KeyPathComparator(\.likes, order: .reverse))
    }
}

/// Likes count for less as a post ages: a simplified "hot" ranking
struct Trending: RankingStrategy {
    let name = "Trending"
    var gravity = 1.5

    func rank(_ posts: [Post]) -> [Post] {
        func score(_ post: Post) -> Double {
            Double(post.likes) / pow(Double(post.hoursOld + 2), gravity)
        }
        return posts.sorted { score($0) > score($1) }
    }
}

/// The context: it holds a strategy and uses it, without asking which one it is
struct FeedRanker {
    var strategy: any RankingStrategy

    func titles(for posts: [Post]) -> [String] {
        strategy.rank(posts).map(\.title)
    }
}

let posts = [
    Post(title: "Release notes", likes: 40, hoursOld: 1),
    Post(title: "Design review", likes: 300, hoursOld: 48),
    Post(title: "Lunch poll", likes: 200, hoursOld: 5),
]

var ranker = FeedRanker(strategy: Newest())
let options: [any RankingStrategy] = [Newest(), MostLiked(), Trending()]
for option in options {
    ranker.strategy = option
    print("\(option.name): \(ranker.titles(for: posts))")
}

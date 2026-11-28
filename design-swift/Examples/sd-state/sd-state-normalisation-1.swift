// Generated from src/dsa/design/content/lessons/sd-state/sd-state-normalisation.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

// What the API sends: each post carries a full copy of its author
struct PostPayload: Decodable {
    let id: Int
    let text: String
    let author: UserPayload
}

struct UserPayload: Decodable {
    let id: Int
    let name: String
}

// What the app stores: each entity once, related by id
struct User {
    let id: Int
    var name: String
}

struct Post {
    let id: Int
    let text: String
    let authorID: Int
}

struct FeedStore {
    private(set) var users: [Int: User] = [:]
    private(set) var posts: [Int: Post] = [:]
    private(set) var feed: [Int] = []

    mutating func ingest(_ payloads: [PostPayload]) {
        for payload in payloads {
            users[payload.author.id] = User(id: payload.author.id, name: payload.author.name)
            posts[payload.id] = Post(id: payload.id, text: payload.text, authorID: payload.author.id)
        }
        feed = payloads.map(\.id)
    }

    mutating func rename(user id: Int, to name: String) {
        users[id]?.name = name
    }

    /// A selector: joins the tables into what each row shows
    func rows() -> [String] {
        feed.compactMap { id in
            guard let post = posts[id], let author = users[post.authorID] else { return nil }
            return "\(author.name): \(post.text)"
        }
    }
}

let json = """
[
  { "id": 1, "text": "Shipping Swift 6 today", "author": { "id": 7, "name": "Ada" } },
  { "id": 2, "text": "Observation is great", "author": { "id": 9, "name": "Grace" } },
  { "id": 3, "text": "Strict concurrency: done", "author": { "id": 7, "name": "Ada" } }
]
"""

var store = FeedStore()
store.ingest(try JSONDecoder().decode([PostPayload].self, from: Data(json.utf8)))
print("Stored", store.users.count, "users for", store.posts.count, "posts")

store.rename(user: 7, to: "Ada Lovelace")
for row in store.rows() {
    print(row)
}

// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-factory-method.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Payload {
    let type: String
    let fields: [String: String]
}

protocol Card {
    var summary: String { get }
}

struct ArticleCard: Card {
    let title: String
    var summary: String { "Article: \(title)" }
}

struct VideoCard: Card {
    let seconds: Int
    var summary: String { "Video, \(seconds) s" }
}

struct CardFactory {
    typealias Maker = (Payload) -> (any Card)?
    private var makers: [String: Maker] = [:]

    mutating func register(_ type: String, make: @escaping Maker) {
        makers[type] = make
    }

    func make(_ payload: Payload) -> (any Card)? {
        makers[payload.type]?(payload)
    }
}

var factory = CardFactory()
factory.register("article") { payload in
    payload.fields["title"].map { ArticleCard(title: $0) }
}
factory.register("video") { payload in
    payload.fields["seconds"].flatMap(Int.init).map { VideoCard(seconds: $0) }
}

let feed = [
    Payload(type: "article", fields: ["title": "Factories in Swift"]),
    Payload(type: "poll", fields: ["question": "Tabs or spaces?"]),
    Payload(type: "video", fields: ["seconds": "95"]),
    Payload(type: "video", fields: ["seconds": "soon"]),
]

for payload in feed {
    print(factory.make(payload)?.summary ?? "skipped \(payload.type)")
}

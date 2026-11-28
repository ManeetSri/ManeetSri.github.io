// Generated from src/dsa/content/lessons/hashing/hash-custom-keys.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Road: Hashable {
    let from: String
    let to: String

    init(_ a: String, _ b: String) {
        from = min(a, b)
        to = max(a, b)
    }
}

let roads: Set<Road> = [
    Road("Leeds", "York"),
    Road("York", "Leeds"),
    Road("Leeds", "Hull"),
]
print(roads.count)
print(roads.contains(Road("Hull", "Leeds")))

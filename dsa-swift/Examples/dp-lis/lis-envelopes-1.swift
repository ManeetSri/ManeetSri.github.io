// Generated from src/dsa/content/lessons/dp-lis/lis-envelopes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Envelope {
    let width: Int
    let height: Int
}

func fits(_ inner: Envelope, inside outer: Envelope) -> Bool {
    inner.width < outer.width && inner.height < outer.height
}

func deepestNesting(_ envelopes: [Envelope]) -> Int {
    let sorted = envelopes.sorted { $0.width < $1.width }
    var depth = Array(repeating: 1, count: sorted.count)   // the longest chain ending with envelope i
    for i in sorted.indices {
        for j in 0..<i where fits(sorted[j], inside: sorted[i]) {
            depth[i] = max(depth[i], depth[j] + 1)
        }
    }
    return depth.max() ?? 0
}

let envelopes = [
    Envelope(width: 5, height: 4), Envelope(width: 6, height: 4), Envelope(width: 6, height: 7),
    Envelope(width: 2, height: 3), Envelope(width: 6, height: 5),
]
print(deepestNesting(envelopes))

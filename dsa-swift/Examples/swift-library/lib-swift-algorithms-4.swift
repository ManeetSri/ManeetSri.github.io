// Generated from src/dsa/content/lessons/swift-library/lib-swift-algorithms.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let colours = ["red", "green", "blue"]

// cycled(): repeat forever; here, as many as you take
let stripes = (0..<7).map { colours[$0 % colours.count] }
print(stripes)

// indexed(): real indexes, even on a slice
let scores = [55, 72, 91, 64, 88]
let lastThree = scores[2...]
for (offset, score) in lastThree.enumerated() {
    print("enumerated", offset, score)
}
for (index, score) in zip(lastThree.indices, lastThree) {
    print("indexed", index, score)
}

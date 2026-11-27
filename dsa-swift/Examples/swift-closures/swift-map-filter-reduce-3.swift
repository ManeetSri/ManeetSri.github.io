// Generated from src/dsa/content/lessons/swift-closures/swift-map-filter-reduce.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let scores = [72, 38, 50, 91, 45]

var passes: [Int] = []
for score in scores {
    if score >= 50 {
        passes.append(score)
    }
}
print(passes)

let alsoPasses = scores.filter { $0 >= 50 }
print(alsoPasses)

let evens = (1...10).filter { $0 % 2 == 0 }
print(evens)

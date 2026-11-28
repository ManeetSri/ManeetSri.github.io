// Generated from src/dsa/content/lessons/swift-closures/swift-compactmap-flatmap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let words = ["apple", "", "kiwi", "", "plum"]
let firstLetters = words.compactMap { $0.first }
print(firstLetters)

let maybeScores: [Int?] = [7, nil, 3, nil]
let realScores = maybeScores.compactMap { $0 }
print(realScores)

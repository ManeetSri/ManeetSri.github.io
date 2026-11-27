// Generated from src/dsa/content/lessons/swift-closures/swift-sorting-searching-api.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [15, 3, 42, 8, 27]

print(numbers.sorted(by: >))
print(numbers.sorted { $0 % 10 < $1 % 10 })

let words = ["banana", "fig", "cherry", "kiwi"]
print(words.sorted { $0.count < $1.count })
